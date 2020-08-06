% computes the shortest distance between two locations in the hand
function distOnHand_generateboundarytable()

load hand
hand = ~bwmorph(~hand,'thin',inf); % one pixel boundaries
hand([534 535],[307 307])=0; % hack to close wrist contour
hand(535,153:307)=0; % hack to close wrist contour
hand=flipud(hand); % change coordinates system
hand=imfill(~hand,'holes');
hand=imresize(hand,1/2);
hand2=imdilate(hand,strel('disk',1));

% coordinates of inside point at the boundary
bound=bwboundaries(hand);
bound=bound{1}(:,[2 1])*2;

% external boundary
bound2=bwboundaries(hand2);
bound2=bound2{1}(:,[2 1])*2;

[origin,theta,pxl_per_mm,regionprop]=plot_hand(nan);
rot=[cos(theta) -sin(theta);sin(theta) cos(theta)];

% convert to hand coordinates
bound=bsxfun(@minus,bound,origin);
bound=bound/pxl_per_mm;
bound=bound*rot;

bound2=bsxfun(@minus,bound2,origin);
bound2=bound2/pxl_per_mm;
bound2=bound2*rot;


p=bound2(1:end-1,:);
r=diff(bound2);

x=bound(:,1);
y=bound(:,2);
boundt=zeros(170000,2,'uint32');

kk=0;
for ii=1:length(x)
    m=[-p(:,1)+x(ii) -p(:,2)+y(ii)];
    o=m(:,1).*r(:,2)-m(:,2).*r(:,1);
    
    for jj=ii+1:length(x)
        % check if cross the boundary
        s1=[x(jj)-x(ii) y(jj)-y(ii)];
        n1=r(:,1)*s1(2)-r(:,2)*s1(1);
        u1=o./n1;
        t1=(m(:,1)*s1(2)-m(:,2)*s1(1))./n1;
        % if does not cross the boundary
        if(isempty(find(u1<=1 & u1>=0 & t1<=1 & t1>=0,1)))
            kk=kk+1;
            boundt(kk,:)=[ii,jj];
        end
    end
end
boundt=boundt(1:kk,:);
save distOnHand_boundt p r bound boundt
