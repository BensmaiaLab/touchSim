%
% PLOT_HAND
%
% Draws a hand with different subparts.
%
% inputs: ax handle to plot on (if nan, does not plot but return outputs)
%         set 'names' to true to show subpart names (default: false)
%         set 'axes' to true to make axes visible (default: false)
%         set 'centers' to true to plot a point on subparts centers 
%                 (default: false)
%         set 'afferents' with an afferent population to add colored dots at
%         afferent locations
%         set 'color' to Nx3 matrix to override afferent default colors
%         set 'region' to a string (ex: 'D2d') to only plot part of hand
%         set 'scalebar' to true to make scalebar visible (default: true)
%
% output: origin: origin of the hand reference frame in pixels
%         theta: rotation angle from pixel coord to hand coord
%         pxl_per_mm: scaling constant
%         regionprop: properties of the different subparts
%


function [orig,theta,pxl_per_mm,regionprop]=plot_hand(varargin)
% if first argument is an handle
if(~isempty(varargin) & (ishandle(varargin{1}) | isnan(varargin{1})))
    ax=varargin{1};
    varargin(1)=[];
else
    ax=gca;
end

p = inputParser;
addParamValue(p,'names', false);  % toggle region names visibility
addParamValue(p,'scalebar', true);  % toggle scalebar visibility
addParamValue(p,'axes', false);  % toggle axes visibility
addParamValue(p,'centers', false); % toggle centers visibility
addParamValue(p,'afferents', []); % plot afferents on hand
addParamValue(p,'color', []); % override afferent default colors
addParamValue(p,'region', []); % select hand region to plot
addParamValue(p,'rotate', 0); % rotate hand
addParamValue(p,'fill', 0); % fill hand with color (e.g. [.9 .9 .9])

p.parse(varargin{:})
names_flag=p.Results.names;
axes_flag=p.Results.axes;
centers_flag=p.Results.centers;
ap=p.Results.afferents;
col=p.Results.color;
region=p.Results.region;
scalebar_flag=p.Results.scalebar;
phi=p.Results.rotate;
fillcol=p.Results.fill;

load hand  % load hand image

hand = ~bwmorph(~hand,'thin',inf); % one pixel boundaries
hand([534 535],[307 307])=0; % hack to close wrist contour
hand=flipud(hand); % change coordinates system

pxl_per_mm=1/0.4579;

% extract different hand zones from BW image
CC = bwconncomp(hand,4);
s = regionprops(CC,'Centroid','BoundingBox','FilledImage');
s=s(2:end); % remove external part

% tag each zone
s(2).Tags{1}='D1';    s(2).Tags{2}='p';    s(2).Tags{3}='f';
s(1).Tags{1}='D1';    s(1).Tags{2}='d';    s(1).Tags{3}='t';
s(6).Tags{1}='D2';    s(6).Tags{2}='p';    s(6).Tags{3}='f';
s(5).Tags{1}='D2';    s(5).Tags{2}='m';    s(5).Tags{3}='f';
s(3).Tags{1}='D2';    s(3).Tags{2}='d';    s(3).Tags{3}='t';
s(11).Tags{1}='D3';   s(11).Tags{2}='p';   s(11).Tags{3}='f';
s(13).Tags{1}='D3';    s(13).Tags{2}='m';  s(13).Tags{3}='f';
s(14).Tags{1}='D3';   s(14).Tags{2}='d';   s(14).Tags{3}='t';
s(15).Tags{1}='D4';   s(15).Tags{2}='p';   s(15).Tags{3}='f';
s(17).Tags{1}='D4';   s(17).Tags{2}='m';   s(17).Tags{3}='f';
s(18).Tags{1}='D4';   s(18).Tags{2}='d';   s(18).Tags{3}='t';
s(19).Tags{1}='D5';   s(19).Tags{2}='p';   s(19).Tags{3}='f';
s(20).Tags{1}='D5';   s(20).Tags{2}='m';   s(20).Tags{3}='f';
s(21).Tags{1}='D5';   s(21).Tags{2}='d';   s(21).Tags{3}='t';
s(4).Tags{1}='P';     s(4).Tags{2}='w1';   s(4).Tags{3}='p';
s(7).Tags{1}='P';     s(7).Tags{2}='w2';   s(7).Tags{3}='p';
s(12).Tags{1}='P';   s(12).Tags{2}='w3';   s(12).Tags{3}='p';
s(16).Tags{1}='P';    s(16).Tags{2}='w4';  s(16).Tags{3}='p';
s(10).Tags{1}='P';    s(10).Tags{2}='p1';  s(10).Tags{3}='p';
s(9).Tags{1}='P';     s(9).Tags{2}='p2';   s(9).Tags{3}='p';
s(8).Tags{1}='W';     s(8).Tags{2}='';     s(8).Tags{3}='p';

regnum=length(s);

% get centroids coordinates
xy=reshape([s(:).Centroid],2,[])'; 
xy=xy*[cosd(phi) sind(phi);-sind(phi) cosd(phi)];

% calculate X axis aligned to D2 based on regression on centroids
xcoefs=[xy([3 5 6 7],1) ones(4,1)]\xy([3 5 6 7],2);
% move centroids on X=0
xy(3,1)=(xy(3,2)-xcoefs(2))/xcoefs(1);
xy(5,1)=(xy(5,2)-xcoefs(2))/xcoefs(1);
xy(6,1)=(xy(6,2)-xcoefs(2))/xcoefs(1);
xy(7,1)=(xy(7,2)-xcoefs(2))/xcoefs(1);
s(3).Centroid=xy(3,:);
s(5).Centroid=xy(5,:);
s(6).Centroid=xy(6,:);
s(7).Centroid=xy(7,:);

% calculate Y axis coefficients
theta=atan(xcoefs(1));
rot=[cos(-theta) -sin(-theta);sin(-theta) cos(-theta)];
orig=xy(3,:);

% refs points for axes plots
X=[orig; orig+60*[1 0]*rot];
Y=[orig; orig+60*[0 1]*rot];

for ii=1:regnum
    % generate each region boundary
    B = bwboundaries(s(ii).FilledImage);
    coord=bsxfun(@plus,B{1}(:,[2 1]),s(ii).BoundingBox(1:2)-.5);
    coord=coord*[cosd(-phi) -sind(-phi);sind(-phi) cosd(-phi)];
    s(ii).Boundary=coord;
end
regionprop=s;

tags = reshape([s.Tags],3,[])';
if isempty(region)
    idx = setdiff(1:length(s),8);
else
    match = regexp(region,'[dDpPwWmMdDfFtT]\d?','match');
    idx = strmatch(upper(match{1}),tags(:,1));
    if length(match)>1
        idx = intersect(idx,strmatch(lower(match{2}),tags(:,2)));
    end
end

if ishandle(ax)
    set(ax,'XColor','none','YColor','none')
    set(ax,'xtick',[],'ytick',[],'nextplot','add')
    if(centers_flag)
        plot(ax,xy(idx,1),xy(idx,2),'k.','markersize',20);
    end
    
    for ii=1:length(idx)
        plot(ax,smooth(s(idx(ii)).Boundary(:,1),8),...
            smooth(s(idx(ii)).Boundary(:,2),8),...
            'color',[1 1 1]*.6,'linewidth',2)
        if(any(fillcol))
            axes(ax)
            smooth(s(idx(ii)).Boundary(:,1),8)
            smooth(s(idx(ii)).Boundary(:,2),8)
            patch(smooth(s(idx(ii)).Boundary(:,1),8),...
                smooth(s(idx(ii)).Boundary(:,2),8),fillcol,...
                'edgecolor','none')
        end
        
        if(names_flag)
            h=text(xy(idx(ii),1),xy(idx(ii),2)-10,...
                [s(idx(ii)).Tags{1} s(idx(ii)).Tags{2}],'parent',ax);
            set(h,'HorizontalAlignment','center')
        end
        %axis equal
    end
    
    if(axes_flag)
        c=[0.6350    0.0780    0.1840];
        plot(ax,X(:,1),X(:,2),'r-',Y(:,1),Y(:,2),'r-')
        quiver(X(1,1),X(1,2),X(2,1)-X(1,1),X(2,2)-X(1,2),0,...
            'linew',2,'col',[0.6350    0.0780    0.1840],...
            'maxheadsize',.5)
        quiver(Y(1,1),Y(1,2),Y(2,1)-Y(1,1),Y(2,2)-Y(1,2),0,...
            'linew',2,'col',[0.6350    0.0780    0.1840],...
            'maxheadsize',.5)
        text(orig(1)-30,orig(2)+16,'(0,0)','par',ax,'fontw','bold','col',c)
        text(orig(1)+30,orig(2)+25,'Y','par',ax,'fontw','bold','col',c)
        text(orig(1)-0,orig(2)-40,'X','par',ax,'fontw','bold','col',c)
    end
    axis(ax,'equal');
    
    % scale bar (btw 1 and 5 cm)
    if scalebar_flag
        xl = get(gca,'xlim');
        yl = get(gca,'ylim');
        set(gca,'xlimmode','manual','ylimmode','manual')
        w=max(min(floor(diff(xl)/pxl_per_mm/10/4),5),1);
        text(xl(1)+w*5*pxl_per_mm,yl(1)+0.06*diff(ylim),...
            [num2str(w*10) ' mm'],'horiz','center')
        plot([xl(1) xl(1) xl(1)+w*10*pxl_per_mm*[1 1]],...
            [yl(1)+0.025*diff(ylim) yl(1) yl(1) yl(1)+0.025*diff(ylim)],'k-')
    end
end

if(~isempty(ap))
    if isempty(col)
        col=bsxfun(@times,ap.iSA1',affcol(1))+...
            bsxfun(@times,ap.iRA',affcol(2))+...
            bsxfun(@times,ap.iPC',affcol(3));
    end
    
    loc=ap.location;
    loc(isnan(sum(col,2)),:) = [];
    col(isnan(sum(col,2)),:) = [];
    
    loc=loc*rot;    loc=loc*pxl_per_mm;    loc=bsxfun(@plus,loc,orig);
    scatter(ax,loc(:,1),loc(:,2),25,col,'filled')
end
