function pixel_locs = hand2pixel(hand_locs)
% locs = hand2pixel(hand_locs)
% Transforms from hand coordinates to pixel coordinates.

[origin,theta,pxl_per_mm] = plot_hand(NaN);
rot = [cos(-theta) -sin(-theta);sin(-theta) cos(-theta)];

pixel_locs = hand_locs*rot;
pixel_locs = pixel_locs*pxl_per_mm;
pixel_locs = bsxfun(@plus,pixel_locs,origin);
