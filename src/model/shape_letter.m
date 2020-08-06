function pins = shape_letter(letter,wid,pins_per_mm)
% pins = shape_letter(letter,wid,pins_per_mm)

if nargin<3
    pins_per_mm = 10;
end

if nargin<2 || isempty(wid)
    wid = 5;
end

if nargin<1 || isempty(letter)
    letter = 'A';
end

assert(ischar(letter));

h = figure('Visible','off');
axis off
text(0.1,0.5,letter(1),'FontSize',250)

A = print2array(h);
close(h)

A = mean(A,3)-255;
[a,b] = size(A);
[x,y] = meshgrid(linspace(-wid/2/a*b,wid/2/a*b,b),linspace(-wid/2,wid/2,a));
[X,Y] = meshgrid(linspace(-wid/2/a*b,wid/2/a*b,wid/a*b*pins_per_mm),linspace(-wid/2,wid/2,wid*pins_per_mm));
A = interp2(x,y,A,X,Y);
%A(A==0) = NaN;
%A = A/max(A(:));
pins = [X(A~=0) Y(A~=0)];
