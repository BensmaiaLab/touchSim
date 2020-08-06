function udyn=CircLoadDynWave(dynProfile,Ploc,PRad,Rloc,Rdepth,sfreq,flag_distOnHand)
% compute shift and decay only once for each unique x,y coord
[~,ia,ic]=unique(Rloc,'rows');

nsamp=size(dynProfile,1);
npin=size(dynProfile,2);
nrec=length(ia);

if(flag_distOnHand)
    dr=distOnHand(Ploc,Rloc(ia,:));
else
    dx = bsxfun(@minus,Ploc(:,1),Rloc(ia,1)');    % (npin,nrec)
    dy = bsxfun(@minus,Ploc(:,2),Rloc(ia,2)');    % (npin,nrec)
    dr = sqrt(dx.^2 + dy.^2);
end

% delay (everything is synchronous under the probe)
rdel=dr-PRad;
rdel(rdel<0)=0;
delay = (rdel/8000); % 8000 is the wave velocity in mm/s

% decay (=skin deflection decay given by Sneddon 1946)
decay = single(1/PRad/pi*asin(PRad./dr));
decay(dr<=PRad)=1/2/PRad;

% construct interpolation functions for each pin and delays the propagation
t=(1/sfreq:1/sfreq:size(dynProfile,1)/sfreq)';
udyn=zeros(nsamp,nrec,'single');

v=ver('matlab');
if(str2double(v.Version)>9)
    for jj=1:npin
        loc_delays=t-delay(jj,:);
        F = griddedInterpolant(t,dynProfile(:,jj),'linear');
        delayed=F(loc_delays);
        udyn=udyn+delayed.*decay(jj,:);
    end
else
    for jj=1:npin
        loc_delays=bsxfun(@minus,t,delay(jj,:));
        F = griddedInterpolant(t,dynProfile(:,jj),'linear');
        delayed=F(loc_delays);
        udyn=udyn+bsxfun(@times,delayed,decay(jj,:));
    end
end

% copy results to all receptors at the same place
udyn=udyn(:,ic);

% z decay is 1/z^2
udyn=double(bsxfun(@rdivide,udyn,(Rdepth.^2)'));