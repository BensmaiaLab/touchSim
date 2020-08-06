function a = affpop_grid(dist,max_extent,class,idx,varargin)
% a = affpop_grid(dist,max_extent,class,idx,varargin)

if nargin<2 || isempty(max_extent)
    max_extent = 10;
end

if nargin<1 || isempty(dist)
    dist = 1;
end

locs = -max_extent/2:dist:max_extent/2;

a = AfferentPopulation;

for l1=1:length(locs)
    for l2=1:length(locs)
        if nargin<3 || isempty(idx)
            a_sub = affpop_single_models([locs(l1) locs(l2)],[],varargin{:});
            a.afferents = [a.afferents a_sub.afferents];
        else
            a.afferents = [a.afferents Afferent(class,'location',[locs(l1) locs(l2)],'idx',idx),varargin{:}];
        end
    end
end
