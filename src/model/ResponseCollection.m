classdef ResponseCollection < handle
    
    properties
        affpop@AfferentPopulation scalar
        responses@Response vector
        stimulus
    end
    
    properties (Dependent = true, SetAccess = private)
        rate
        duration
    end
    
    methods
        
        function obj = ResponseCollection(affpop,responses,stimulus)
            obj.affpop = affpop;
            obj.responses = responses;
            obj.stimulus = stimulus;
        end
        
        function rate = get.rate(obj)
            rate = [obj.responses.rate];
            rate = reshape(rate,[],obj.affpop.num)';
        end
        
        function dur = get.duration(obj)
            dur = obj.stimulus.duration;
        end
        
        function r = psth(obj,bin_width)
            if nargin<2
                bin_width = 10;
            end
            for a = 1:length(obj.responses)
                r(:,a) = obj.responses(a).psth(bin_width);
            end
        end
        
        function plot(obj,varargin)
            col=bsxfun(@times,obj.affpop.iSA1',affcol(1))+...
                bsxfun(@times,obj.affpop.iRA',affcol(2))+...
                bsxfun(@times,obj.affpop.iPC',affcol(3));
            plot_spikes({obj.responses(:).spikes},'color',col,varargin{:})
        end
    end
end
