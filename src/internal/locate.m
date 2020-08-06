function region = locate(locations)
% region = locate(locations)
% Determines hand region for each afferent or pin location.
% locations: can be of type Afferent, AfferentPopulation, or Stimulus; or
% Nx2 array of afferent/pin locations.
% region: nested cell array of size N(1x3) containing region tags for each
% location. 
% Example: to extract all coarse regions for full hand model, use
% t = locate(affpop_hand());
% reg = cellfun(@(x)x{1},t,'UniformOutput',false);

if isobject(locations)
    locations = locations.location;
end

load hand
tags = cell(size(hand'));

[~,~,~,regionprop]=plot_hand(nan);

loc = hand2pixel(locations);
loc = round(loc);

for n=1:length(regionprop)
    idx = find(regionprop(n).FilledImage);
    [j1,j2] = ind2sub(size(regionprop(n).FilledImage),idx);
    for i=1:length(idx)
        tags{j2(i)+regionprop(n).BoundingBox(1)-0.5,j1(i)+regionprop(n).BoundingBox(2)-0.5} =...
            regionprop(n).Tags;
    end
end

ind = zeros(size(loc,1),1);
for i=1:size(loc,1)
    try
        ind(i) = sub2ind(size(hand'),loc(i,1),loc(i,2));
    catch
        ind(i) = 1;
    end
end

region = tags(ind);
