classdef Response < handle
    
    properties
        spikes@double vector
        afferent@Afferent scalar
        propagated_struct
    end
    
    properties (Dependent = true, SetAccess = private)
        rate
        duration
    end
    
    methods
        
        function obj = Response(afferent,propagated_struct,spikes)
            if nargin==0
                obj.spikes = [];
            elseif nargin==2
                obj = response(afferent,propagated_struct);
            else
                obj.spikes = spikes;
                obj.afferent = afferent;
                obj.propagated_struct = propagated_struct;
            end
        end
        
        function rate = get.rate(obj)
            rate = length(obj.spikes)/obj.duration;
        end
        
        function dur = get.duration(obj)
            dur=length(obj.propagated_struct.stat_comp)/...
                obj.propagated_struct.sampling_frequency;
        end
        
        function r = psth(obj,bin_width)
            if nargin<2
                bin_width = 10;
            end
            
            edges = 0:bin_width/1000:obj.duration;
            r = histc(obj.spikes,edges);
            r(end) = [];
        end
        
        function ax=plot(obj,ax)
            a=obj.afferent;
            idx=a.iSA1+a.iRA*2+a.iPC*3;
            plot_spikes(obj.spikes,'color',affcol(idx))
        end
        
    end
end
