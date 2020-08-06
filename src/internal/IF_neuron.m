% IF neuron model
% inputs should be sampled at 5000 Hz

function spikes = IF_neuron(aff,stat_comp,dyn_comp)
% spikes = IF_neuron(aff,prop_struct)

sf=5000; % sampling frequency is 5000 Hz

stimi = reshape(stat_comp,[],1);
dstimi = reshape(dyn_comp,[],1);

% Make basis for post-spike current ---------------
IF_ihbasis;
ih = ihbasis*reshape(aff.parameters(11:12),[],1);

if aff.parameters(1)>0
    [b,a] = butter(3,aff.parameters(1)*4/1000,'low');
    stimi = filter(b,a,stimi);
    dstimi = filter(b,a,dstimi);
end

ddstimi = [diff(dstimi);0];

stim_expanded = [stimi -stimi dstimi -dstimi ddstimi -ddstimi];
stim_expanded(stim_expanded<0)=0;

tau = aff.parameters(10);      % decay time const
vleak = 0;                    % resting potential

Iinj = stim_expanded * aff.parameters(2:7)';

if aff.noisy
    Iinj = Iinj + aff.parameters(9)*randn(length(Iinj),1);
end

if aff.parameters(8)>0
    Iinj = aff.parameters(8)*Iinj./(aff.parameters(8)+abs(Iinj));
    Iinj(isnan(Iinj)) = 0;
end

vthr = 1;   % threshold potential
vr = 0;     % reset potential

slen = size(Iinj,1);
nh = size(ih,1);
ih_counter = nh+1;

Vmem = vleak*ones(slen,1);
Sp = zeros(slen,1);

for ii=2:slen  % Outer loop: 1 iter per time bin of input
    
    if ih_counter>nh
        Vmem(ii) =  Vmem(ii-1)+(-(Vmem(ii-1)-vleak)/tau + Iinj(ii));
    else
        Vmem(ii) =  Vmem(ii-1)+(-(Vmem(ii-1)-vleak)/tau + Iinj(ii) + ih(ih_counter));
        ih_counter = ih_counter + 1;
    end
    
    if Vmem(ii)>vthr && ih_counter>5
        Sp(ii) = 1;
        Vmem(ii) = vr;
        ih_counter = 1;
    end
end

spikes = [find(Sp)/sf + aff.parameters(13)/1000]';
