function [dist,nodes]=distOnHand(xy_pin,xy_aff)

% straight distance
tic; fprintf('straight distance')
dx = bsxfun(@minus,xy_pin(:,1),xy_aff(:,1)');    % (npin,nrec)
dy = bsxfun(@minus,xy_pin(:,2),xy_aff(:,2)');    % (npin,nrec)
dist = sqrt(dx.^2 + dy.^2);
toc

% get hand boundaries + edge length table idx
load distOnHand_boundt

% check which paths are not straight
tic; fprintf('find notStraightEdges   ')
kk=0;
notStraightEdges=zeros(size(xy_pin,1)*size(xy_aff,1),2);
for ii=1:size(xy_pin,1)
    m=[-p(:,1)+xy_pin(ii,1) -p(:,2)+xy_pin(ii,2)];
    o=m(:,1).*r(:,2)-m(:,2).*r(:,1);
    for jj=1:size(xy_aff,1)
        % check if cross the boundary
        s1=xy_aff(jj,:)-xy_pin(ii,:);
        n1=r(:,1)*s1(2)-r(:,2)*s1(1);
        u1=o./n1;
        t1=(m(:,1)*s1(2)-m(:,2)*s1(1))./n1;
        % if does not cross the boundary
        if(~isempty(find(u1<=1 & u1>=0 & t1<=1 & t1>=0,1)))
            kk=kk+1;
            notStraightEdges(kk,:)=[ii,jj];
        end
    end
end
notStraightEdges=notStraightEdges(1:kk,:);
toc

% list of unique (notStraight) start and ending points
[unipin,~,icpin]=unique(notStraightEdges(:,1));
[uniaff,~,icaff]=unique(notStraightEdges(:,2));

% algorithm is faster with few starting points and many ending point.
% Invert if needed to make it faster.
flag_invert=length(unipin)>length(uniaff);
if(flag_invert)
    xy_start=xy_aff;
    xy_end=xy_pin;
    
    unistart=uniaff;
    uniend=unipin;
    
    icstart=icaff;
    icend=icpin;
else
    xy_start=xy_pin;
    xy_end=xy_aff;
    
    unistart=unipin;
    uniend=uniaff;
    
    icstart=icpin;
    icend=icaff;
end


% find non-zeros indices to build Dijkstra sparse matrix
x=[bound(:,1);xy_start(unistart,1);xy_end(uniend,1)];
y=[bound(:,2);xy_start(unistart,2);xy_end(uniend,2)];
tic; fprintf('find non zeros indices in Dijkstra sparse matrix   ')
kk=0;
loctable=zeros(length(x)*round(length(x)/2),2);
for ii=1:length(x)
    m=[-p(:,1)+x(ii) -p(:,2)+y(ii)];
    o=m(:,1).*r(:,2)-m(:,2).*r(:,1);
    
    % matrix is upperdiagonal (unidirectionnal Dijkstra)
    for jj=max(length(bound)+1,ii+1):length(x)
        % check if cross the boundary
        s1=[x(jj)-x(ii) y(jj)-y(ii)];
        n1=r(:,1)*s1(2)-r(:,2)*s1(1);
        u1=o./n1;
        t1=(m(:,1)*s1(2)-m(:,2)*s1(1))./n1;
        % if does not cross the boundary
        if(isempty(find(u1<=1 & u1>=0 & t1<=1 & t1>=0,1)))
            kk=kk+1;
            loctable(kk,:)=[ii,jj];
        end
    end
end
toc
% append to indices from the border
loctable=loctable(1:kk,:);table=[boundt;loctable];

% build matrix with weights = distance
val=hypot(x(table(:,1))-x(table(:,2)),y(table(:,1))-y(table(:,2)));
R = sparse(double(table(:,2)),double(table(:,1)),double(val(:)),...
    length(x),length(x));

% compute Dijkstra (loop over starting (=pin) nodes)
tic; fprintf('run Dijkstra algorithm   ')

lup=length(unistart);
distDijkstra=zeros(size(icstart));
s=size(bound,1);
dist_cell=cell(lup,1);
parfor ii=1:lup
    S=s+ii;
    [dist_,~]=graphshortestpath(R,S,'Directed',false);
    T=s+lup+icend(icstart==ii);
    dist_cell{ii}=dist_(T);
%     path_cell{ii}=path_(T);
end
for ii=1:lup
    distDijkstra(icstart==ii)=dist_cell{ii};
%     path=path_cell{ii};
%     if(~iscell(path))
%         path={path};
%     end
%     nodes(icstart==ii)=path;
end

% for ii=1:length(nodes)
%     nodes{ii}=[x(nodes{ii}) y(nodes{ii})];
% end
toc

% replace dist values
linearInd = sub2ind(size(dist), notStraightEdges(:,1), notStraightEdges(:,2));
dist(linearInd)=distDijkstra;