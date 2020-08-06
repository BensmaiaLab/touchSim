function trace = apply_ramp(trace,len,samp_freq)
% trace = apply_ramp(trace,len,samp_freq)

% Do nothing is ramp length is zero
if len==0
    return;
end

% Interpret 'len' as number of bins if no sampling frequency is given, and as
% time in seconds if sampling frequency is provided
if nargin<3
    bins = len;
else
    bins = round(len*samp_freq);
end

trace(1:bins) = linspace(0,1,bins) .* trace(1:bins);
trace(end-bins+1:end) = linspace(1,0,bins) .* trace(end-bins+1:end);
