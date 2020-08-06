function col=affcol(n)

col=[50 160 40;30 120 180;255 127 0;0 0 0]/255;

if(nargin>0)
    col=col(n,:);
end