function [shape,pin_offset] = shape_square_grating(shift,pins_per_mm,period,...
    ridge_width,radius,depth,noedge)
% [shape,pin_offset] = shape_square_grating(shift,pins_per_mm,period,ridge_width,radius,depth,noedge)
% creates gratings shape over a circular patch, with edge cutted borders
%
% inputs : (all are optional)
%          shift: shift towards x direction (in pins, default=0)
%          pins_per_mm : number of pins per mm (default=5)
%          period : spatial period of the gratings (in pins, default=10)
%          ridge_width: ridge w (in pins, default=period/2)
%          radius : overall contact radius in mm (default=8)
%          depth : groove depth in mm (default=1)
%          noedge : flag to set edge_cutting or not (default=true)
%
% output : shape: 2D pin coordinates
%          pin_offset: indentation offset for each pin


if (nargin==0)|| isempty(shift)
    shift=0;
end
if (nargin<2) || isempty(pins_per_mm)
    pins_per_mm=5;
end
if (nargin<3) || isempty(period)
    period=10;
end
if (nargin<4) || isempty(ridge_width)
    ridge_width=period/2;
end
if (nargin<5) || isempty(radius)
    radius=7;
end
if (nargin<6) || isempty(depth)
    depth=1;
end
if (nargin<7)
    noedge=true;
end

[x,y]=meshgrid(-radius:1/pins_per_mm:radius,-radius:1/pins_per_mm:radius);
r=hypot(x,y); x(r>radius)=nan; y(r>radius)=nan;

pin_offset=zeros(size(x));
z=x*pins_per_mm+shift+1000;
pin_offset(rem(z,period)<ridge_width)=1;

spanmm=1;
if(noedge)
    pin_offset=pin_offset.*(erf(-(r-radius+(spanmm))*2/(spanmm))+1)/2*depth;
end
pin_offset(pin_offset<0)=nan;

pin_offset=pin_offset(:);
x=x(:);
y=y(:);
shape=[x(~isnan(x)),y(~isnan(x))];
pin_offset=pin_offset(~isnan(x));
