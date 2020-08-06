function shape = shape_bar(width,height,angle,pins_per_mm)
% shape = shape_bar(width,height,angle,pins_per_mm)

if nargin<4
    pins_per_mm = 10;
end

if nargin<3 || isempty(angle)
    angle = 0;
end

if nargin<2 || isempty(height)
    height = 0.5;
end

if nargin<1 || isempty(width)
    width = 5;
end

[x,y] = meshgrid(linspace(-width/2,width/2,width*pins_per_mm),linspace(-height/2,height/2,height*pins_per_mm));
shape = [x(:) y(:)];
shape = ([cosd(angle) -sind(angle); sind(angle) cosd(angle)]* shape')';
