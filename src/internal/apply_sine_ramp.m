function trace = apply_sine_ramp(trace,len,samp_freq)
% trace = apply_sine_ramp(trace,len,samp_freq)

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

trace(1:bins) = (cos(linspace(pi,2*pi,bins))/2 +0.5) .* trace(1:bins);
trace(end-bins+1:end) = (cos(linspace(0,pi,bins))/2 +0.5) .* trace(end-bins+1:end);
