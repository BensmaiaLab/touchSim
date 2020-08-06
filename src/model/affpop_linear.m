function a = affpop_linear(dist,max_extent,class,idx,varargin)
% a = affpop_linear(dist,max_extent,class,idx,varargin)
% Generates afferents on a line extending from the origin
% dist: distance between neighboring afferent locations
% max_extent: distance of farthest afferent
% class: afferent class
% idx: afferent model index
% varargin: afferent constructor arguments

if nargin<3
    class = [];
end

if nargin<2  || isempty(max_extent)
    max_extent = 160;
end

if nargin<1 || isempty(dist)
    dist = 1;
end

locs = 0:dist:max_extent;
a = AfferentPopulation;

for l=1:length(locs)
    if nargin<4 || isempty(idx)
        a_sub = affpop_single_models([locs(l) 0],class,varargin{:});
        a.afferents(end+(1:length(a_sub.afferents))) = a_sub.afferents;
    else
        a.afferents(l)=Afferent(class,'location',[locs(l) 0],'idx',idx,varargin{:});
    end
end
