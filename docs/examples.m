%% Understanding the hand coordinate system
% Afferent and stimulus locations are expressed in a 2D coordinate system
% that is centered on the tip of the index finger, with the first axis
% running along the index finger and the second axis orthogonal to that.

figure
plot_hand('axes',1)

%%
% When no locations are given |Afferent| and |Stimulus| objects are
% automatically placed at the origin, i.e. the index fingertip.

%% Setup a single afferent and stimulus, and calculate response
% This example creates a single PC afferents, manually creates a simple
% stimulus, and then calculates the response.

% Create a PC afferent
a = Afferent('PC','idx',1);

% Generate a 80 Hz sine wave with 150 um amplitude
sf = 5000; 
t = (1/sf:1/sf:1)'; 
trace = sin(2*pi*80*t)*0.15;
rad = 0.5;% pin with 0.5 mm radius
xy = [0 0]; % pin coordinate
s = Stimulus(trace,xy,sf,rad); 

% Calculate response
r = a.response(s);

% Show response
r.rate
plot(r)

%%
% For commonly used stimuli, such as ramp-and-hold stimuli and sinusoidal
% vibrations, the model includes functions that allow generating such
% stimuli easily.

% generate the same stimulus using the stim_sine function:
s = stim_sine(80,.15);
plot(s)


%% Test expanded skin mech
% Sine wave
sf = 5000; 
rad = 0.1;
t = (1/sf:1/sf:1)'; 
sine_wave = sin(2*pi*80*t);
num_pins = 51;

% Pin coordinates
[x, y] = deal(linspace(-1,1,num_pins));
[X,Y] = meshgrid(x,y); 
loc = [X(:), Y(:)];

% Create stimulus trace
trace = zeros(length(t), size(loc,1));
idx = all(loc == 0, 2);
trace(:, idx) = sine_wave;
% trace(:, 50) = sine_wave;
% trace(:, 1000) = sine_wave;


% Create stimulus
s = Stimulus(trace,loc,sf,rad); 

%% Try plotting
z = s.indentprofile';
z = reshape(z, [num_pins,num_pins,length(t)]);

p = s.trace';
p = reshape(p, [num_pins,num_pins,length(t)]);

zlims = [min(z,[], 'all'), max(z,[],'all') + 1];
xlim = [min(s.location(:,1)), max(s.location(:,1))];
ylim = [min(s.location(:,2)), max(s.location(:,2))];

num_pins = sqrt(size(s.location, 1));
xloc = reshape(s.location(:,1), num_pins, num_pins);
yloc = reshape(s.location(:,2), num_pins, num_pins);

% Create pin mesh
[pX,pY,pZ] = cylinder(s.pin_radius * 0.9);

clf; shg
for i = 1:100
    cla(); hold on

    % Plot all of the pins
    pt = p(:,:,i);
    [px, py] = find(pt ~= 0);
    for j = 1:length(pidx)
        surf(pX + xloc(px,py), ...
             pY + yloc(px,py), ...
             pZ + pt(px,py) + 0.01, ...
             'FaceColor', [.6 .6 .6])
        fill3(pX(1,:) + xloc(px,py), ...
              pY(1,:) + yloc(px,py), ...
              pZ(1,:) + pt(px,py) + 0.01, [.6 .6 .6]);
        % scatter3(xloc(px,py), yloc(px,py), pt(px,py) + 0.01, 50)
    end


    % Plot the skin mesh
    surf(x,y,squeeze(z(:,:,i)))
    clim(zlims)

    % Format
    set(gca, 'ZLim', zlims, ...
             'XLim', xlim, ...
             'YLim', ylim, ...
             'View', [-25 25])
    pause(0.01)
end



%%

% Move stimulus 5 mm away and calculate response.
s = stim_sine(80,.15,[],[],[5 0]);

r2 = a.response(s);
r2.rate

% Plot response
figure
plot(r2)

%% Setup an afferent population and calculate response

% Generate a population of afferents located on the index finger
a = affpop_hand('D2');

% Count number of PC receptors
sum(a.iPC)

%%

% Plot location of receptors
figure
plot(a)

%%

% calculate response
r = a.response(s);

% plot response (spike raster)
figure
plot(r)

%%

% plot response intensity
figure
rates=r.rate;
rates(a.iSA1)=rates(a.iSA1)/max(rates(a.iSA1));
rates(a.iRA)=rates(a.iRA)/max(rates(a.iRA));
rates(a.iPC)=rates(a.iPC)/max(rates(a.iPC));
plot(a,[],'rate',rates)
