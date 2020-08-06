function a = affpop_single_models(loc,class,varargin)
% a = get_all_single_models(loc,class,varargin)
% Returns AfferentPopulation containing all single neuron models

if nargin<1 || isempty(loc)
    loc = [0 0];
end

a = AfferentPopulation;
parameters=IF_parameters;

if nargin<2 || isempty(class) || strcmpi(class,'SA1') || strcmpi(class,'SA')
    for i=1:length(parameters.sa)
        a.afferents(i) = Afferent('SA1',loc,'idx',i,varargin{:});
    end
end

if  nargin<2 || isempty(class) || strcmpi(class,'RA')
    l=length(a.afferents);
    for i=1:length(parameters.ra)
        a.afferents(i+l) = Afferent('RA',loc,'idx',i,varargin{:});
    end
end

if nargin<2 || isempty(class) || strcmpi(class,'PC')
    l=length(a.afferents);
    for i=1:length(parameters.pc)
        a.afferents(i+l) = Afferent('PC',loc,'idx',i,varargin{:});
    end
end
