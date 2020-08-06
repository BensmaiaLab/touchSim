function s = stim_grasp(digits,trace,delay)
% s = stim_grasp(digits,trace,delay)
% Generates stimulus that simulates multi-finger grasp
% * digits: vector with finger indices (1-5); default: [1 2], simultating
% 2-finger grasp using thumb and index fingers
% * trace: Stimulus object containing a single pin and time course, whose
% parameters and trace will be applied to all pins in the grasp; default:
% stim_ramp(0.75,.25,[],[],0.05,'lin',5).
% * delay: delays between individual fingers when starting their trace;
% default: zeros(1,numel(digits))

if nargin<1
    digits = [1 2];
end

if nargin<2
    trace = stim_ramp(0.75,.25,[],[],0.05,'lin',5);
end

if nargin<3 || isemtpy(delay)
    delay = zeros(1,numel(digits));
end
assert(numel(digits)==numel(delay));

contacts = [1 3 14 18 21];
contacts = contacts(digits);
[~,~,~,regionprop] = plot_hand(NaN);
for c=1:length(contacts)
    contact_locs(c,:) = regionprop(contacts(c)).Centroid;
    
end
contact_locs = pixel2hand(contact_locs);

s = pad(pad(stim_indent_shape(contact_locs,trace),delay),0.05);
