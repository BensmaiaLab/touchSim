% input is a cell of time vectors of different length or a time vector

function plot_spikes(varargin)

p=inputParser;
p.addRequired('spikestimes'); % cell vector of spike times
p.addParamValue('neuron_offset',0);   % scalar integer counting neuron offset
p.addParamValue('neuron_scale',1);   % y axis scaling
p.addParamValue('time_offset',0);   % time offset of the first spike
p.addParamValue('time_scale',1);   % time scaling
p.addParamValue('color',[0 0 0]); % either 1 color for all, or (#neurons,3)
p.addParamValue('linewidth',1.6);  % bar linewidth
p.addParamValue('parenthandle',gcf,@ishandle); % fig or axis
p.addParamValue('psth',0);    % show psth below (0=off, other=binning win duration in sec)
p.addParamValue('rates','off'); % show mean rate on the right
p.addParamValue('psd','off');   % show spike train spectrum
p.addParamValue('hold','off');  % hold previous plots ('on' if offset ~=0)
p.addParamValue('title','');
p.addParamValue('spike_num',0);
p.addParamValue('psth_duration',[]) % time duration of psth trace


parse(p,varargin{:});

fh=p.Results.parenthandle;
spikestimes=p.Results.spikestimes;
noffset=p.Results.neuron_offset;
nscale=p.Results.neuron_scale;
toffset=p.Results.time_offset;
tscale=p.Results.time_scale;
color=p.Results.color;
lw=p.Results.linewidth;
psth=p.Results.psth;
psd=p.Results.psd;
rates=p.Results.rates;
holdfig=p.Results.hold;
titlevar=p.Results.title;
spike_num=p.Results.spike_num;
psth_duration=p.Results.psth_duration;


if(strcmp('axes',get(fh,'type')))
    ax=fh;
    psd='off';
    rates='off';
    psth=0;
else
    figure(fh)
    if(strcmp(psd,'off')&&strcmp(rates,'off')&&psth==0)
        ax=gca;
    else
        ax=subplot(4,4,[1:3 5:7 9:11]);
    end
end

if(isnumeric(spikestimes))
    spikestimes={spikestimes};
end

neurcount=length(spikestimes);
hold(ax,holdfig);

% set up colors
if(size(color,1)~=neurcount),    color=color(1,:);end
[C,ia,ic] = unique(color,'rows');
colcount=length(ia);
xfull=cell(colcount,1);
yfull=cell(colcount,1);
ratevector=cell(colcount,1);
if(size(color,1)~=neurcount),    ic=ones(length(spikestimes),1);end

for ii=1:colcount
    ratevector{ii}=zeros(1,neurcount);
end

if(spike_num)
    fprintf('Spike count: ')
end
% compute coordinates (and spike rates)
for ii=1:neurcount
    spikes=spikestimes{ii}(:)'*tscale;
    spikestimes{ii}=spikes;
    if(~isempty(spikes))
        ratevector{ic(ii)}(ii)=numel(spikes)/max(spikes);
    end
    s=size(spikes);
    xlin=[spikes; spikes; nan(s)];  xlin=xlin(:)+toffset;
    ylin=[zeros(s)+.02; zeros(s)+.98; nan(s)]; ylin=(ylin(:)+ii-1+noffset)*nscale;
    
    xfull{ic(ii)}=[xfull{ic(ii)};xlin];
    yfull{ic(ii)}=[yfull{ic(ii)};ylin];
    if(spike_num)
        fprintf('%d ',length(spikes))
    end
end
if(spike_num)
    fprintf('\n')
end
% plot data
for ii=1:colcount
    plot(ax,xfull{ii},yfull{ii},'color',C(ii,:),'linewidth',lw);
    hold(ax,'on');
    box(ax,'off')
end

if ~(strcmp(holdfig,'on') || noffset~=0)
    hold(ax,'off');
end

xlabel(ax,'Time [s]')
ylabel(ax,'Neuron #')

if(~isempty(titlevar))
    title(ax,titlevar)
end

if(psth~=0)
    binned=bin_spikes(spikestimes,psth,psth_duration);
    subplot(4,4,13:15)
    hold(gca,holdfig)
    val=sum(binned,2)/psth/length(spikestimes);
    stairs((0:size(binned,1))'*psth,[0;val],'color',color(1,:),'linew',1)
    box off; %hold on
    xlim(get(ax,'xlim'))
    linkaxes([ax gca],'x')
    
end

if(strcmp(rates,'on'))
    subplot(4,4,[4 8 12])
    for ii=1:colcount
        barh((1:neurcount)-.5+noffset,ratevector{ii},'facecolor',C(ii,:),'edgecolor','none'); hold on
    end
    ylim(get(ax,'ylim'))
    set(gca,'xgrid','on')
    box off
    linkaxes([ax gca],'y')
end

if(strcmp(psd,'on'))
    subplot(4,4,16)
    for ii=1:neurcount
        times=spikestimes{ii}(:)';
        binned=zeros(ceil(max(times)*1000)+1,1);
        binned(ceil(times*1000))=1;
        binnedfft=abs(fft(binned));
        if(size(color,1)==1)
            if(ischar(color))
                color=rem(floor((strfind('kbgcrmyw', color) - 1)...
                    * [0.25 0.5 1]), 2);
            end
            c=color;
        else
            c=color(ii,:);
        end
        semilogx(linspace(0,500,round(length(binned)/2)),...
            binnedfft(1:round(end/2)),'color',[c .3]); hold on
        xlim([5 500])
        set(gca,'xgrid','on')
    end
    hold off; box off
end

axes(ax)
