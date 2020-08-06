function s = stim_indent_shape(shape,trace,pin_offset,samp_freq)
% s = stim_indent_shape(shape,trace,offset,samp_freq)
% Indents object into skin
% shape: pin positions making up object shape, e.g. shape_letter().
% trace: indentation trace, e.g. stim_ramp().
% pin_offset: indentation offset for each pin, allows complex shapes that 
% are not flat, default: 0.
% samp_freq: sampling frequency, only necessary if trace is not Stimulus
% object.
%
% Example: s = stim_indent_shape(shape_letter(),stim_ramp());

if isobject(trace)
    t = trace.trace(:,1);
    samp_freq = trace.sampling_frequency;
    pin_radius = trace.pin_radius;
else
    t = reshape(trace,[],1);
    pin_radius = 0.05;
end

% make sure pin_radius is not too big
if size(shape,1)>1
    if size(shape,1)>=3
        try
            % triangulation for efficiency
            tri=delaunay(shape(:,1),shape(:,2));
            tri=tri(:,[1:end 1]);
            dx = diff(reshape(shape(tri,1),size(tri)),1,2);
            dy = diff(reshape(shape(tri,2),size(tri)),1,2);
            dmin = sqrt(min(dx(:).^2+dy(:).^2));
        catch
            % brute force, if that doesn't work
            dx = shape(:,1)-shape(:,1)';
            dy = shape(:,2)-shape(:,2)';
            dist = sqrt(dx(:).^2+dy(:).^2);
            dist(dist==0) = NaN;
            dmin = min(dist);
        end
    elseif size(shape,1)==2
        dmin = sqrt(sum((shape(1,:)-shape(2,:)).^2));
    end
    if dmin<(2*pin_radius)
        pin_radius = dmin/2;
        warning(['Pin radius too big for object shape and has been adjusted to '...
            num2str(pin_radius) '.']);
    end
end

trace = repmat(t,[1 size(shape,1)]);

if nargin>2 && ~isempty(pin_offset)
    if length(pin_offset)==1
        pin_offset = repmat(pin_offset,size(trace,1),1);
    end
    trace = trace + repmat(reshape(pin_offset,1,[]),size(trace,1),1);
end

s = Stimulus(trace,shape,samp_freq,pin_radius);
