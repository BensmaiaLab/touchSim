function s = stim_sine(freq,amp,phase,len,loc,samp_freq,ramp_len,pin_size,pre_indent)
% s = stim_sine(freq,amp,phase,len,loc,samp_freq,ramp_len,pin_size,pre_indent)
% Generates indenting complex sine stimulus
% freq: vector of frequencies in Hz
% amp: vector of amplitudes in mm
% phase: vector of phases in degrees, default: 0
% len: stimulus duration in s, default: 1
% loc: stimulus location in mm, default: [0 0]
% samp_freq: sampling frequency in Hz, default: 5000
% ramp_len: length of on and off ramps in s, default: 0.05
% pin_size: radius of probe pin in mm, default: 0.5
% pre_indent: static indentation throughout trial, default: 0

assert(length(freq)==length(amp));

if nargin<9
    pre_indent = 0;
end

if nargin<8 || isempty(pin_size)
    pin_size = 0.5;
end

if nargin<7 || isempty(ramp_len)
    ramp_len = 0.05;
end
 
if nargin<6 || isempty(samp_freq)
    samp_freq = 5000;
end

if nargin<5 || isempty(loc)
    loc = [0 0];
end

if nargin<4 || isempty(len)
    len = 1;
end

if nargin<3 || isempty(phase)
    phase = zeros(1, length(freq));
end

trace = zeros(1, samp_freq*len);
for j = 1:length(freq)
    trace = trace + ...
        amp(j)*sin(phase(j)*pi/180 + linspace(0,2*pi*freq(j)*len,samp_freq*len));
end
trace = apply_ramp(trace,ramp_len,samp_freq);
trace = trace+pre_indent;

s = Stimulus(reshape(trace,[],1),loc,samp_freq,pin_size);
