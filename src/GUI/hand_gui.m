%
% HAND GUI
%
% Helps to generate Afferent population objects
% Show coordinate system used in the model
% Provide a easy way to get coordinates of a given point on the hand
%
% Output :  Afferent population generated.


function AP=hand_gui()

% create afferent population object
afferents=struct([]);

% afferent densities
density.SA1.p=10;   density.SA1.f=30;   density.SA1.t=70;
density.RA.p=25;    density.RA.f=40;    density.RA.t=140;
density.PC.p=10;    density.PC.f=10;    density.PC.t=25;

% set up GUI
fig.main=figure('position',[70 100 1200 900],'visible', 'on');
fig.axis= axes('parent',fig.main,'Position',[0.03 0.05 .54 .9]);

fig.text.maintitle=uicontrol(fig.main,'style','pushbutton','unit','norm','pos',[.60,.9,.38,.04],'String','Generate Afferent Population Tool','callback',@debug_cb,'backg',[.8 .8 .8]);
fig.text.addtitle=uicontrol(fig.main,'style','text','unit','norm','pos',[.60,.84,.18,.04],'String','Add');
fig.text.listtitle=uicontrol(fig.main,'style','text','unit','norm','pos',[.80,.84,.18,.04],'String','List');
fig.text.logtitle=uicontrol(fig.main,'style','text','unit','norm','pos',[.60,.44,.18,.04],'String','Error Logs');
fig.text.number=uicontrol(fig.main,'style','text','unit','norm','pos',[.80,.79,.18,.04],'String','0');

fig.list.entries=uicontrol(fig.main,'style','listbox','unit','norm','pos',[.80,.18,.18,.60]);
fig.list.log=uicontrol(fig.main,'style','listbox','unit','norm','pos',[.60,.18,.18,.25],'string',{'--Log start--'});

fig.but.manu=uicontrol(fig.main,'style','pushbutton','unit','norm','pos',[.60,.70,.18,.04],'String','Manually','callback',@manual_cb);
fig.but.cent=uicontrol(fig.main,'style','pushbutton','unit','norm','pos',[.60,.65,.18,.04],'String','Centered on Subpart','callback',@center_cb);
fig.but.hand=uicontrol(fig.main,'style','pushbutton','unit','norm','pos',[.60,.60,.18,.04],'String','Whole Hand','callback',@homogHand_cb);
fig.but.part=uicontrol(fig.main,'style','pushbutton','unit','norm','pos',[.60,.55,.18,.04],'String','Homogeneous Part','callback',@homogPart_cb);
fig.but.subp=uicontrol(fig.main,'style','pushbutton','unit','norm','pos',[.60,.50,.18,.04],'String','Homogeneous Subpart','callback',@homogSubpart_cb);
fig.but.remo=uicontrol(fig.main,'style','pushbutton','unit','norm','pos',[.80,.13,.18,.04],'String','Remove','callback',@remove_cb);
fig.but.gene=uicontrol(fig.main,'style','pushbutton','unit','norm','pos',[.60,.05,.38,.04],'String','Generate Afferent Population Now','callback',@generate_cb);
fig.but.getc=uicontrol(fig.main,'style','pushbutton','unit','norm','pos',[.60,.13,.18,.04],'String','Get Coordinates','callback',@get_coord_cb);

fig.gr.typ = uibuttongroup('pos',[.60,.75,.08,.08],'unit','norm');
fig.radio.sa1= uicontrol('Style','Radio','String','SA1','unit','norm','pos',[.05 .66 .9 .33],'parent',fig.gr.typ,'Value',1,'backg',affcol(1),'tag','1');
fig.radio.ra = uicontrol('Style','Radio','String','RA','unit','norm','pos',[.05 .33 .9 .33],'parent',fig.gr.typ,'backg',affcol(2),'tag','2');
fig.radio.pc = uicontrol('Style','Radio','String','PC','unit','norm','pos',[.05 0 .9 .33],'parent',fig.gr.typ,'backg',affcol(3),'tag','3');

fig.gr.dens = uibuttongroup('pos',[.68,.75,.1,.08],'unit','norm');
fig.radio.full= uicontrol('Style','Radio','String','Full density','unit','norm','pos',[.0 .66 .9 .33],'parent',fig.gr.dens,'Value',1);
fig.radio.half = uicontrol('Style','Radio','String','Half','unit','norm','pos',[.0 .33 .9 .33],'parent',fig.gr.dens);
fig.radio.custom = uicontrol('Style','Radio','String','Custom:','unit','norm','pos',[.0 0 .5 .33],'parent',fig.gr.dens);
fig.edit.custom = uicontrol('Style','edit','String','','unit','norm','pos',[.5 0 .2 .33],'parent',fig.gr.dens);
fig.text.custom = uicontrol('Style','text','String','u/cm^2','unit','norm','pos',[.7 0 .3 .27],'parent',fig.gr.dens);

% plot the hand
[origin,theta,pxl_per_mm,s]=plot_hand(fig.axis);
regnum=length(s);

set(fig.main,'WindowButtonMotionFcn',@update_coords)

    function update_coords(src,callbackdata)
        cp = fig.axis.CurrentPoint;
        if cp(1)>405
            title([])
        else
            cp = pixel2hand(cp(1,1:2));
            title(sprintf('x: %0.1f, y: %0.1f', cp(1,1), cp(1,2)))
        end
    end

% ref frame rotation angle and matrix
rot=[cos(theta) -sin(theta);sin(theta) cos(theta)];

AP=[];
waitfor(fig.main)

%add manually
    function manual_cb(~,~)
        [coord,r]=get_point();
        if(isempty(r)),return;end
        add_afferent('manual',coord,[s(r).Tags{1} s(r).Tags{2}])
    end

%add centered
    function center_cb(~,~)
        [~,r]=get_point();
        if(isempty(r)),return;end
        coord=s(r).Centroid; %centroid
        add_afferent('center',coord,[s(r).Tags{1} s(r).Tags{2}])
    end

% add homog subpart
    function homogSubpart_cb(~,~)
        [~,r]=get_point();
        if(isempty(r)),return;end
        coord=homog_sampling(r);
        add_afferent('homog_subpart',coord,[s(r).Tags{1} s(r).Tags{2}])
    end

% add homog part
    function homogPart_cb(~,~)
        [~,r]=get_point();
        if(isempty(r)),return;end
        coord=[];
        for jj=1:regnum
            if(strcmp(s(r).Tags{1},s(jj).Tags{1}))
                coord=[coord;homog_sampling(jj)];
            end
        end
        add_afferent('homog_part',coord,[s(r).Tags{1}])
    end

% add homog hand
    function homogHand_cb(~,~)
        coord=[];
        for jj=1:regnum
            if(jj==8), continue;end  % not in wrist
            coord=[coord;homog_sampling(jj)];
        end
        add_afferent('homog_hand',coord,'hand')
    end

% homogeneous subpart
    function coord=homog_sampling(reg)
        sel=get(fig.gr.typ,'SelectedObject');
        dens=density.(get(sel,'String')).(s(reg).Tags{3}); %unit per cm^2
        sel_dens=get(fig.gr.dens,'SelectedObject');
        if(strcmp(get(sel_dens,'String'),'Half'))
            dens=dens/2;
        end
        if(strcmp(get(sel_dens,'String'),'Custom:'))
            dens=str2double(get(fig.edit.custom,'String'));
        end
        ldens=sqrt(dens)/10/pxl_per_mm;
        b=s(reg).BoundingBox;
        [x,y]=meshgrid(b(1):1/ldens:b(1)+b(3),b(2):1/ldens:b(2)+b(4));
        x=x+randn(size(x))/ldens/5;       y=y+randn(size(y))/ldens/5;
        in=inpolygon(x(:),y(:),s(reg).Boundary(:,1),s(reg).Boundary(:,2));
        coord=[x(in),y(in)];
    end

% get a valid coordinate
    function [coord,region]=get_point()
        coord=ginput(1); in=zeros(regnum,1);
        for jj=1:regnum
            in(jj) = inpolygon(coord(1),coord(2),s(jj).Boundary(:,1),s(jj).Boundary(:,2));
        end
        
        region=find(in);
        if(isempty(region))
            add_log('Out of the hand');
            coord=[]; region=[];
        end
        if(length(region)>2)
            add_log('For an unknown reason, two regions were selected. Please restart');
            coord=[]; region=[];
        end
    end

% add log string
    function add_log(str)
        curr_str=flipud(get(fig.list.log,'String'));
        curr_str{end+1,1}=str;
        set(fig.list.log,'String',flipud(curr_str));
    end


% add afferents groups
    function add_afferent(entry,coord,region)
        curr=length(afferents)+1;
        sel=get(fig.gr.typ,'SelectedObject');
        num=str2double(get(sel,'tag'));
        hplot(1)=plot(coord(:,1),coord(:,2),'.','color',affcol(num),'markersize',15);
        afferents(curr).entry=entry;
        afferents(curr).type=get(sel,'String');
        afferents(curr).locs=coord;
        afferents(curr).region=region;
        if(size(coord,1)==1)
            hplot(2)=text(coord(:,1)+5,coord(:,2),num2str(curr));
            set(hplot(2),'color',affcol(num))
        end
        afferents(curr).handle=hplot;
        str=get(fig.list.entries,'String');
        str{end+1}=[num2str(curr) ' ' get(sel,'String') ' ' region ' (' entry ')'];
        set(fig.list.entries,'String',str)
    end

% remove afferent
    function remove_cb(~,~)
        num=get(fig.list.entries,'Value');
        str=get(fig.list.entries,'String');
        str(num)=[];
        set(fig.list.entries,'Value',1)
        set(fig.list.entries,'String',str)
        delete(afferents(num).handle);
        afferents(num)=[];
    end

% generate afferent population
    function generate_cb(~,~)
        AP=AfferentPopulation();
        for jj=1:length(afferents)
            locs=change_coord_sys(afferents(jj).locs);
            AP= AP.add_afferents(afferents(jj).type,locs);
        end
        close(fig.main)
    end

% return coordinates of a point on the hand to matlab console
    function get_coord_cb(~,~)
        [coord,r]=get_point();
        if(isempty(r)),return;end
        fprintf('Coordinates: [ %2.2f , %2.2f ] \n',change_coord_sys(coord))
        fprintf('Hand part/subpart: %s%s \n\n',s(r).Tags{1},s(r).Tags{2})
    end

% center at origin, scale to mm, align to finger.
    function new_locs=change_coord_sys(locs)
        locs=bsxfun(@minus,locs,origin);
        locs=locs/pxl_per_mm;
        new_locs=locs*rot;
    end

% debug routine run when you click on 'Generate Afferent Population Tool'
    function debug_cb(~,~)
        fprintf('Calling debug function')
        afferents
    end
end