classdef Afferent < handle
    
    properties
        class@char vector
        parameters@double vector
        location@double vector
        depth@double scalar
        idx@int16 scalar
        noisy@logical scalar
        model@char vector
    end
    
    properties (Dependent = true, SetAccess = private)
        iSA1, iRA, iPC
    end
    
    methods
        
        function obj = Afferent(class,varargin)
            p = inputParser;
            addRequired(p,'class');
            addOptional(p,'location',[0 0]);
            addParamValue(p,'depth', []);
            addParamValue(p,'parameters',[]);
            addParamValue(p,'idx',[]);
            addParamValue(p,'noisy',true);
            addParamValue(p,'delay',false);
            addParamValue(p,'model','IF');
            parse(p,class,varargin{:});
            inputs=p.Results;
            
            % set class (see set.class function)
            obj.class = inputs.class;
            obj.location = inputs.location;
            obj.model = inputs.model;
            
            if(isempty(inputs.depth))
                switch class
                    case 'SA1'
                        obj.depth = .3;
                    case 'RA'
                        obj.depth = 1.6;
                    case 'PC'
                        obj.depth = 2; % should check literature for real value
                end
            else
                obj.depth = inputs.depth;
            end
            
            obj.noisy = inputs.noisy;
            
            if ~isempty(inputs.parameters)
                obj.idx=0;
                obj.parameters = inputs.parameters;
            else
                idx=inputs.idx;
                switch inputs.model
                    case 'IF'
                        param=IF_parameters;
                    case 'GLM' % option not provided, please use IF model
                        warning('option not provided, please use IF model')
                        param=GLM_parameters; 
                    otherwise
                        error('unknown Afferent model!')
                end
                param=param.(lower(obj.class(1:2)));
                l=length(param);
                if(isempty(idx))
                    obj.idx = ceil(rand*l);
                else
                    if(idx>l)
                        obj.idx=mod(idx-1,l)+1;
                        warning('Specified model not found.')
                    else
                        obj.idx=idx;
                    end
                end
                obj.parameters=param{obj.idx};
            end
            if(~inputs.delay)
                obj.parameters(13)=0;
            end
        end
        
        function set.class(obj,class)
            % check inputs
            if strcmpi(class,'SA')
                class = 'SA1';
            end
            if ~(strcmpi(class,'SA1') || strcmpi(class,'RA') || strcmpi(class,'PC'))
                error('Class must be SA1, RA, or PC.')
            end
            
            % define class
            obj.class = upper(class);
        end
        
        function iSA1 = get.iSA1(obj)
            iSA1 = strcmp('SA1',obj.class);
        end
        
        function iRA = get.iRA(obj)
            iRA = strcmp('RA',obj.class);
        end
        
        function iPC = get.iPC(obj)
            iPC = strcmp('PC',obj.class);
        end
        
        function r = response(obj,stim,flag_distOnHand)
            if nargin<3
                flag_distOnHand=0;
            end
            
            % propagates complex spatial stimulus to a single trace
            % at a given location
            if(isa(stim,'Stimulus')) % single afferent
                prop_struct=propagate(stim,obj,flag_distOnHand);
            else % when called by Afferent population (already propagated)
                prop_struct=stim;
            end
            
            % resample trace at 5000Hz for the spiking models
            stat_comp=resample(prop_struct.stat_comp,5000,prop_struct.sampling_frequency);
            dyn_comp =resample(prop_struct.dyn_comp,5000,prop_struct.sampling_frequency);
            
            switch obj.model
                case 'IF'
                    r = Response(obj,prop_struct,IF_neuron(obj,stat_comp,dyn_comp));
                case 'GLM'
                    r = Response(obj,prop_struct,GLM_neuron(obj,stat_comp,dyn_comp));
                otherwise
                    error('unknown Afferent model!')
            end
            
        end
        
        function ax=plot(obj,ax,col,varargin)
            affclass={'SA1','RA','PC'};
            
            % plot on 1 or 3 hands
            ohidx=find(strcmp(varargin,'onehand'));
            if(~isempty(ohidx))
                oh=varargin{ohidx+1};
                varargin(ohidx:ohidx+1)=[];
            else
                oh=false;
            end
            
            % transparency based on rate
            rateidx=find(strcmp(varargin,'rate'));
            if(~isempty(rateidx))
                rate=varargin{rateidx+1};
                varargin(rateidx:rateidx+1)=[];
                if(rate<.1) % do not plot small value
                    return
                end
            else
                rate=1;
            end
            
            if(nargin<2||isempty(ax))
                if(~oh)
                    ax=zeros(3,1);
                    for ii=1:3
                        ax(ii)=subplot(1,3,ii);
                        [origin,theta,pxl_per_mm]=plot_hand(ax(ii),varargin{:});
                    end
                    set(ax,'nextplot','add');
                    set(ax(1),'userdata',[origin,theta,pxl_per_mm])
                    set(ax(1), 'position',[0 0 .33 .9])
                    set(ax(2), 'position',[.33 0 .33 .9])
                    set(ax(3), 'position',[.66 0 .33 .9])
                else
                    ax=[gca gca gca];
                    [origin,theta,pxl_per_mm]=plot_hand(ax(1),varargin{:});
                    set(ax(1),'userdata',[origin,theta,pxl_per_mm])
                end
            else
                info=get(ax(1),'userdata');
                origin=info(1:2);
                theta=info(3);
                pxl_per_mm=info(4);
            end
            rot=[cos(-theta) -sin(-theta);sin(-theta) cos(-theta)];
            loc=obj.location*rot;
            loc=loc*pxl_per_mm;
            loc=bsxfun(@plus,loc,origin);
            affidx=find(strcmp(affclass,obj.class));
            h=plot(ax(affidx),loc(:,1),loc(:,2),'.','markersize',8);
            if(nargin<3||isempty(col)),
                set(h,'color',1-((1-affcol(affidx))*(rate*3/4+1/4)));
            else
                set(h,'color',1-((1-col)*(rate*3/4+1/4)));
            end
            set(gcf,'Color','white');
        end
    end
end
