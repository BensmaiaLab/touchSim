function a = affpop_hand(region,density_ratio,class,varargin)
% a = affpop_hand(region,density_ratio,class,varargin)
% Places receptors on the hand, set region to:
%   [], for full hand
%   'D2' for a full finger, e.g. D2
%   'D2d' for a part, e.g. tip of D2

if nargin<3 || isempty(class)
    afftype = {'SA1','RA','PC'};
else
    afftype = {class};
end

if(~exist('density_ratio','var') || isempty(density_ratio))
    dr=1;
else
    dr=density_ratio;
end

if length(dr)==1
    dr = repmat(dr,1,3);
end

% afferent densities
density.SA1.p=10*dr(3);   density.SA1.f=30*dr(2);   density.SA1.t=70*dr(1);
density.RA.p=25*dr(3);    density.RA.f=40*dr(2);    density.RA.t=140*dr(1);
density.PC.p=10*dr(3);    density.PC.f=10*dr(2);    density.PC.t=25*dr(1);

[~,~,pxl_per_mm,s] = plot_hand(NaN);
tags = reshape([s.Tags],3,[])';

if nargin<1 || isempty(region)
    idx = setdiff(1:length(s),8);
else
    match = regexp(region,'[dDpPwWmMdDfFtT]\d?','match');
    idx = strmatch(upper(match{1}),tags(:,1));
    if length(match)>1
        idx = intersect(idx,strmatch(lower(match{2}),tags(:,2)));
    end
end

a=AfferentPopulation();
for tt=1:length(afftype)
    coord=[];
    for jj=1:length(idx)        
        eval(['dens=density.' afftype{tt} '.' s(idx(jj)).Tags{3} ';']); %unit per cm^2
        ldens = dens/100/pxl_per_mm^2;
        coord=[coord; sample_random_shape(ldens,s(idx(jj)).Boundary)];
    end
    locs = pixel2hand(coord);
    a = a.add_afferents(afftype{tt},locs,varargin{:});
end
