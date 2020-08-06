function shape = shape_circle(radius,pins_per_mm)
% shape = shape_circle(radius,pins_per_mm)

if nargin<2
    pins_per_mm = 10;
end

if(nargin<1) || isempty(radius)
    radius= 2;
end

[x,y] = meshgrid(-ceil(radius):1/pins_per_mm:ceil(radius));
r = hypot(x,y);
shape = [x(:) y(:)];
shape(r>radius,:) = [];
