function hand_locs = pixel2hand(pixel_locs)
% locs = pixel2hand(hand_locs)
% Transforms from pixel coordinates to hand coordinates.

[origin,theta,pxl_per_mm] = plot_hand(NaN);
rot = [cos(-theta) -sin(-theta);sin(-theta) cos(-theta)];

hand_locs = bsxfun(@minus,pixel_locs,origin);
hand_locs = hand_locs/pxl_per_mm;
hand_locs = hand_locs*inv(rot);
