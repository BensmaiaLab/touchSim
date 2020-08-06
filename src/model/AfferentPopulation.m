classdef AfferentPopulation < handle
    
    properties
        afferents@Afferent vector = Afferent.empty;
    end
    
    properties (Dependent = true)
        location
        depth
    end
    
    properties (Dependent = true, SetAccess = private)
        num
        class
        iSA1, iRA, iPC
    end
    
    methods
        
        function obj = AfferentPopulation(afflist)
            if nargin>0
                obj.afferents = afflist;
            end
        end
        
        function num = get.num(obj)
            num = length(obj.afferents);
        end
        
        function class = get.class(obj)
            class = {obj.afferents.class};
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
        
        function location = get.location(obj)
            location = [obj.afferents.location];
            location = reshape(location,2,[])';
        end
        
        function set.location(obj,loc)
            assert(size(obj.location,1)==size(loc,1));
            
            for a=1:obj.num
                obj.afferents(a).location = loc(a,:);
            end
        end
        
        function depth = get.depth(obj)
            depth = [obj.afferents.depth]';
        end
        
        function set.depth(obj,depth)
            assert(size(obj.depth,1)==size(depth,1));
            for a=1:obj.num
                obj.afferents(a).depth = depth(a,:);
            end
        end
        
        function r = response(obj,stim,flag_distOnHand)
            if nargin<3
                flag_distOnHand=0;
            end
            prop_struct=propagate(stim,obj,flag_distOnHand);
            % compute response
            for i=1:obj.num
                res(i) = response(obj.afferents(i),prop_struct(i),...
                    flag_distOnHand);
            end
            r = ResponseCollection(obj,res,stim);
        end
        
        function obj = add_afferents(obj,class,locs,varargin)
            l=size(locs,1);
            for i=1:l
                aff(i) = Afferent(class,locs(i,:),varargin{:});
            end
            obj.afferents(end+(1:l)) = aff;
        end
        
        function plot(obj,col_vec,varargin)
            ax=[];
            % transparency based on rate
            rateidx=find(strcmp(varargin,'rate'));
            if(~isempty(rateidx))
                rate=varargin{rateidx+1};
                varargin(rateidx:rateidx+1)=[];
            else
                rate=ones(size(obj.afferents));
            end
            
            for ii=1:length(obj.afferents)
                if nargin<2 || isempty(col_vec)
                    ax=plot(obj.afferents(ii),ax,[],'rate',rate(ii),varargin{:});
                else
                    ax=plot(obj.afferents(ii),ax,col_vec(ii,:),'rate',rate(ii),varargin{:});
                end
            end
        end
        
    end
end
