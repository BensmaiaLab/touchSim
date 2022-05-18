% Stimulus class

classdef Stimulus < handle
    
    properties(SetAccess = private)
        trace@double = 1+.5*sin(linspace(0,10,5000)*2*pi*10)';  % indentation matrix (nsamples,npins)
        location@double = [0 0];                            % 2D coordinates of each pins (npins,2)
        sampling_frequency@double scalar = 5000;            % sampling frequency of the stimulus
        pin_radius@double scalar =0.05;                     % pin radius
        profile                                             % equivalent load profile
        profiledyn                                          % dynamic load profile
        indentprofile
    end
    
    properties (SetAccess = private, Dependent=true)
        duration                                    % stimulus duration
    end
    
    properties (Access = private, Hidden = true)
        initialized = 0;
    end
    
    methods
        
        % constructor
        function obj = Stimulus(trace,location,sampling_frequency,pin_radius)
            if nargin>3
                obj.pin_radius=pin_radius;
            end
            if nargin>2
                obj.sampling_frequency = sampling_frequency;
            end
            if nargin>1
                obj.location = location;
            end
            if nargin>0
                obj.trace = trace;
            end
            obj.initialized=1;
            obj.compute_profile();
        end
        
        % get total duration of the stimulus
        function duration = get.duration(obj)
            duration = size(obj.trace,1)/obj.sampling_frequency;
        end
        
        % modify stimulus trace
        function set.trace(obj,trace)
            obj.trace = trace;
            obj.compute_profile();
        end
        
        % modify pins locations
        function set.location(obj,location)
            obj.location = location;
            obj.compute_profile();
        end
        
        % modify stimulus frequency
        % update sampling freq (change speed) without change trace and profile
        % update profiledyn accordingly.
        function update_sampling_frequency(obj,new_sf)
            freq_ratio=new_sf/obj.sampling_frequency;
            obj.profiledyn=obj.profiledyn*freq_ratio;
            obj.sampling_frequency=new_sf;
        end
        
        % resample trace at a given frequency
        function resample(obj,sampling_freq)
            sampling_freq = round(sampling_freq);
            dt1=1/obj.sampling_frequency;
            dt2=1/sampling_freq;
            obj.trace = interp1(dt1:dt1:obj.duration,obj.trace,dt2:dt2:obj.duration);
            obj.sampling_frequency = sampling_freq;
        end
        
        % pad trace with zeros at beginning and end
        function obj = pad(obj,len1,len2)
            if nargin<3
                if numel(len1)==1
                    len2 = len1;
                else
                    len2 = max(len1)-len1;
                end
            end
            
            padding1 = zeros(min(len1)*obj.sampling_frequency,size(obj.trace,2));
            padding2 = zeros(max(len2)*obj.sampling_frequency,size(obj.trace,2));
            trace_new = [padding1; obj.trace; padding2];
            
            if numel(len1)>1
                assert(numel(len1)==numel(len2));
                assert(numel(len1)==size(obj.location,1))
                assert(numel(unique(len1+len2))==1);
                shift = (len1-min(len1))*obj.sampling_frequency;
                for n=1:length(shift)
                    trace_new(:,n) = circshift(trace_new(:,n),shift(n));
                end
            end
            
            obj.trace = trace_new;
        end
        
        % compute equivalent force profile based on skin deflection
        function compute_profile(obj)
            if(obj.initialized)
                [obj.profile, obj.profiledyn, obj.indentprofile] = CircIndent2LoadProfile...
                    (single(obj.trace),single(obj.location),...
                    obj.sampling_frequency,obj.pin_radius);
            end
        end
        
        % propagate stimulus to a given point
        function [s,stat_comp,dyn_comp]=propagate(obj,aff,flag_distOnHand)
            % unique locations (only compute propagation once for each loc)
            [~,ia,ic]=unique([aff.location,aff.depth],'rows');
            
            % static part (should be only only SA1)
            idx=aff.iSA1(ia); % compute only on SA1s
            stat_comp=zeros(size(obj.profile,1),length(ia)); % other set to 0
            stat_comp(:,idx)=CircLoadVertStress(obj.profile,obj.location,...
                obj.pin_radius,aff.location(ia(idx),:),aff.depth(ia(idx)));
            
%             stat_comp=CircLoadVertStress(obj.profile,obj.location,...
%                 obj.pin_radius,aff.location(ia,:),aff.depth(ia));

            % dynamic part 
            if(size(obj.profile,1)>1) % only if more than 1 sample
                dyn_comp=CircLoadDynWave(obj.profiledyn,obj.location,...
                    obj.pin_radius,aff.location(ia,:),aff.depth(ia),...
                    obj.sampling_frequency,flag_distOnHand);
            else
                dyn_comp=zeros(1,length(ia));
            end
            
            stat_comp=stat_comp(:,ic);
            dyn_comp=dyn_comp(:,ic);
            
            s=struct;
            for ii=1:size(stat_comp,2)
                s(ii).sampling_frequency=obj.sampling_frequency;
                s(ii).stat_comp=stat_comp(:,ii);
                s(ii).dyn_comp=dyn_comp(:,ii);
            end
        end
        
        % plot stimulus
        function plot(obj)
            
            % pins location on hand
            [origin,theta,pxl_per_mm,regionprop]=plot_hand(nan);
            rot=[cos(-theta) -sin(-theta);sin(-theta) cos(-theta)];
            xy=obj.location; xy=xy*rot; xy=xy*pxl_per_mm;
            xy=bsxfun(@plus,xy,origin);
            
            % determine hand region
            in=false(length(regionprop),1);
            for ii=1:length(regionprop)
                in(ii) = any(inpolygon(xy(:,1),xy(:,2),...
                    regionprop(ii).Boundary(:,1),...
                    regionprop(ii).Boundary(:,2)));
            end
            tags=cat(1,regionprop(in).Tags);
            utags=unique(tags(:,1));
            
            if(size(tags,1)==1) % single subregion
                region=cat(2,tags{1:2});
            elseif(length(utags)==1) % single region
                region=utags;
            else % full hand
                region=[];
            end
            
            % plot
            set(gcf,'pos',[400 560 1000 420])
            ax=subplot(121);
            
            % plot hand region
            plot_hand(ax,'region',region);
            title('Pin locations (click on pin or ''spatial'' to see profiles)')
            
            % plot circles
            t=linspace(0,2*pi,20);
            npin=length(obj.location(:,1));
            xc=[bsxfun(@plus,obj.location(:,1),obj.pin_radius*cos(t)) nan(npin,1)]';
            yc=[bsxfun(@plus,obj.location(:,2),obj.pin_radius*sin(t)) nan(npin,1)]';
            xyc=[xc(:) yc(:)]; xyc=xyc*rot; xyc=xyc*pxl_per_mm;
            xyc=bsxfun(@plus,xyc,origin);
            plot(xyc(:,1),xyc(:,2),'r')
            
            % textbox for spatial frame
            nsamp=size(obj.trace,1);
            uic=uicontrol('Style','slider','visible','off','value',1,...
                'Min',1,'Max',nsamp,'SliderStep',[1/nsamp .1],...
                'pos',[800,20,100,20]);
            
            % clickable pins centers
            h=scatter(xy(:,1),xy(:,2),[],'r','filled','markerfacealpha',0);
            hx=plot(nan,nan,'kx');
            set(h,'ButtonDownFcn',@pointclickfun);
            clickinfo.IntersectionPoint=xy(1,:);
            pointclickfun(h,clickinfo)
            
            % clickable 'spatial' button
            xl=xlim(ax); yl=ylim(ax);
            h=text(xl(1)+.98*diff(xl),yl(1)+.98*diff(yl),'Spatial',...
                'horiz','right','vert','top','parent',ax,...
                'edgec',[.2 .2 .2],'back',[.8 .8 .8]);
            set(h,'ButtonDownFcn',{@textclickfun,'Trace'});
            
            
            function textclickfun(~,~,param)
                if(length(obj.location(:,1))<3)
                    warning('Spatial display only works with at least 3 pins')
                    return
                end
                switch param
                    case 'Trace'
                        var=obj.trace; colgain=[.4 1 1];
                    case 'Profile'
                        var=obj.profile; colgain=[1 .4 1];
                    case 'ProfileDyn'
                        var=obj.profiledyn; colgain=[1 1 .4];
                end
                
                curr=get(uic,'value');
                tri=delaunay(xy);
                axloc=subplot(122); cla(axloc)
                plot_hand(axloc,'region',region);
                title(param)
                hloc=trisurf(tri,xy(:,1),xy(:,2),var(curr,:),'parent',axloc);
                view(2);
                clim=[nanmin(var(:)) nanmax(var(:))];
                if(diff(clim)==0), clim(2)=clim(2)+1; end
                set(axloc,'clim',clim);
                grid off; shading interp; hold off
                set(uic,'visible','on',...
                    'tag',num2str(1),'Callback',{@changeIdx,hloc,var});
                xlloc=xlim(axloc); ylloc=ylim(axloc);
                h1=text(xlloc(1)+.98*diff(xlloc),ylloc(1)+.98*diff(ylloc),'   trace   ',...
                    'horiz','right','vert','top','parent',axloc,...
                    'edgec',[.2 .2 .2],'back',[.8 .8 .8]*colgain(1));
                h2=text(xlloc(1)+.98*diff(xlloc),ylloc(1)+.88*diff(ylloc),'  profile  ',...
                    'horiz','right','vert','top','parent',axloc,...
                    'edgec',[.2 .2 .2],'back',[.8 .8 .8]*colgain(2));
                h3=text(xlloc(1)+.98*diff(xlloc),ylloc(1)+.78*diff(ylloc),'profiledyn',...
                    'horiz','right','vert','top','parent',axloc,...
                    'edgec',[.2 .2 .2],'back',[.8 .8 .8]*colgain(3));
                
                set(h1,'ButtonDownFcn',{@textclickfun,'Trace'})
                set(h2,'ButtonDownFcn',{@textclickfun,'Profile'})
                set(h3,'ButtonDownFcn',{@textclickfun,'ProfileDyn'})
                
                linkaxes([ax,axloc],'xy')
            end
            
            function changeIdx(h,~,plothandle,data)
                curr=round(get(h,'value'));
                set(h,'value',curr)
                set(plothandle,'cdata',data(curr,:))
            end
            
            function pointclickfun(lineh,clickh)
                set(uic,'visible','off')
                % find closest point and extract index
                bcoord=clickh.IntersectionPoint(1:2);
                xs=diff(lineh.Parent.XLim); % correct for x and y different scales
                ys=diff(lineh.Parent.YLim);
                dxdy=bsxfun(@minus,[lineh.XData' lineh.YData'],bcoord);
                dist=hypot(dxdy(:,1)/xs,dxdy(:,2)/ys);
                [~,pidx]=min(dist);
                
                set(hx,'xdata',xy(pidx,1),'ydata',xy(pidx,2))
                
                % time varying signals
                sf=obj.sampling_frequency;
                tloc=1/sf:1/sf:obj.duration;
                axloc=[subplot(322) subplot(324) subplot(326)];
                plot(axloc(1),tloc,obj.trace(:,pidx))
                plot(axloc(2),tloc,obj.profile(:,pidx))
                plot(axloc(3),tloc,obj.profiledyn(:,pidx))
                set(axloc,'box','off')
                set(axloc(2:3),'ytick',0)
                xlabel(axloc(3),'Time [s]')
                ylabel(axloc(1),'Trace [mm]')
                ylabel(axloc(2),'Stat comp [-]')
                ylabel(axloc(3),'Dyn comp [-]')
            end
        end
        
    end
end
