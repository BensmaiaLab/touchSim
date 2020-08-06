function s = stim_ramp(amp,len,loc,samp_freq,ramp_len,ramp_type,pin_size,pre_indent)
% s = stim_ramp(amp,len,loc,samp_freq,ramp_len,ramp_type,pin_size,pre_indent)
% ramp up / hold / ramp down indentation
% amp: amplitude in mm, default: 1
% len: total duration of stimulus in s, default 1
% loc: stimulus location in mm, default [0 0]
% samp_freq: sampling frequency in Hz, default 5000
% ramp_len: duration of on and off ramps in s, default 0.05
% ramp_type: 'lin' or 'sine', default 'lin'.
% pin_size: probe radius in mm.
% pre_indent: static indentation throughout trial, default: 0

if nargin<8
    pre_indent = 0;
end

if nargin<6 || isempty(ramp_type)
    ramp_type = 'lin';
end

if nargin<5 || isempty(ramp_len)
    ramp_len = 0.05;
end

if nargin<4 || isempty(samp_freq)
    samp_freq = 5000;
end

if nargin<3 || isempty(loc)
    loc = [0 0];
end

if nargin<2 || isempty(len)
    len = 1;
end

if nargin<1 || isempty(amp)
    amp = 1;
end

trace = amp*ones(1,round(samp_freq*len));
switch ramp_type
    case 'lin'
        trace = apply_ramp(trace,ramp_len,samp_freq);
    case 'sine'
        trace = apply_sine_ramp(trace,ramp_len,samp_freq);
    otherwise
        error('Unknown ramp type.')
end
trace = trace + pre_indent;

if nargin<7 || isempty(pin_size)
    s = Stimulus(reshape(trace,[],1),loc,samp_freq);
else
    s = Stimulus(reshape(trace,[],1),loc,samp_freq,pin_size);
end
