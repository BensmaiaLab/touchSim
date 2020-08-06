function locs = sample_random_shape(density,polygon)
% locs = sample_random_shape(density,polygon)

density = sqrt(density);

pmin = min(polygon)-0.5;
pmax = max(polygon)+0.5;

[x,y] = meshgrid(pmin(1):1/density:pmax(1),pmin(2):1/density:pmax(2));
x = x+randn(size(x))/density/5;
y = y+randn(size(y))/density/5;
in = inpolygon(x(:),y(:),polygon(:,1),polygon(:,2));
locs = [x(in) y(in)];
