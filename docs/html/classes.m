%% TouchSim classes

%% Afferent
% Object that represents a single tactile afferent.
%
% *Properties*
%
% * |class|: Afferent class, needs to be |'SA1'|, |'RA'|, or |'PC'|.
% * |location|: Location on skin in mm where afferent is terminating,
% default |[0 0]|. Coordinate system is based on the hand model with the
% origin centered on the tip of the index finger.
% * |depth|: Depth of afferent below the skin surface in mm. Default values
% are chosen based on afferent class. In most cases, these values should
% not require changing.
% * |noisy|: Adds noise to membrane potential, if set to true, otherwise
% model runs purely deterministically; default |true|.
% * |delay|: If true, sets delay of afferent response to estimated delay at
% recording site along the nerve, necessary for model fitting but otherwise
% unnecessaryl default |false|.
% * |iSA1|: true, if model is an SA1 afferents. Can be accessed, but not
% set.
% * |iRA|: true, if model is an RA afferent. Can be accessed, but not
% set.
% * |iPC|: true, if model is a PC afferent. Can be accessed, but not
% set.
% * |idx|: model ID, defaults to a random value. For example, if set to 1,
% will select the first model of the respective afferent class. There are 4
% SA1, 9 RA, and 4 PC models in total.
% * |parameters|: a vector containing the 13 parameters for the spiking
% model, is chosen based on afferent class and model ID (|idx|) parameters.
% In general, this parameter should not be set directly.
% * |model|: type of spiking model, always set to |'IF'|.
%
% *Methods*
%
% <html>
% <ul><li><tt>a = Afferent(class,varargin)</tt>: Constructs a Afferent object.
% <ul><li><tt>class</tt>: Afferent class, needs to be 'SA1', 'RA', or
% 'PC'.</li>
% <li><tt>varargin</tt>: Additional afferent parameters: <tt>location:</tt> 
% afferent location, default <tt>[0 0]</tt>; <tt>idx</tt>: afferent model, 
% default chosen randomly from all models of given class; <tt>noisy</tt>: 
% adds input jitter if true, default true; <tt>delay</tt>: adds neural delay if true,
% only needed to match fitting data, default false; <tt>parameters</tt>:
% model parameters, default automatically chosen based on <tt>class</tt>
% and <tt>idx</tt>.</li></ul></li>
% <li><tt>r = response(stim,flag_distOnHand)</tt>:Calculate afferent response
% to given stimulus, returns <tt>Response</tt> object.
% <ul><li><tt>stim</tt>: Stimulus object.</li>
% <li><tt>flag_distOnHand</tt>: Determines whether wave propagation is calculated
% based on geometry of the hand model (if set to true), or based on absolute distance
% alone, ignoring gaps between fingers (if set to false), default false. Activating 
% this setting will increase computation time for wave propagation considerably, but
% this parameter is essential if the responses of afferents all over the hand are
% considered.</li></ul></li>
% <li><tt>plot(ax,col,varargin)</tt>: Generates a figure of the hand with the location
% of the afferent marked.
% <ul><li><tt>ax</tt>: Figure axis to plot in, generates a new figure by default.</li>
% <li><tt>col</tt>: Color of marker, default standard afferent color (SA1: green, 
% RA: blue, PC: orange).</li>
% <li><tt>varargin</tt>: Additional parameters to be passed to <tt>plot_hand</tt>,
% as well as <tt>onehand:</tt> plots only a single hand outline if true, default false; 
% <tt>rate</tt>: adjusts transparency of colored marker based on response rate provided, 
% default no transparency.</li></ul></li></ul>
% </html>
%
% *Examples*

% generate a random PC model
a = Afferent('PC');
a.idx

%%

% pick the first RA model, place at [1 1], and turn off input jitter
a = Afferent('RA','idx',1,'location',[1 1],'noisy',false);
a.location

%%

plot(a,[],[],'onehand',true);

%%

% generate simple ramp stimulus and calculate response
s = stim_ramp([],[],[1 1]);
r = a.response(s);
r.spikes

%%

%% AfferentPopulation
% Object that represents a population of afferents, represented as a vector
% of Afferent objects.
%
% *Properties*
%
% * |afferents|: vector containing Afferent objects. Entries can be added
% and deleted by the user and all other properties will automatically
% update.
% * |num|: Number of afferents in the population. Can be accessed, but not
% set.
% * |class|: Vector containing afferent class of each afferent.
% * |location|: Matrix containing location of each afferent.
% * |depth|: Vector containing depth of each afferent.
% * |iSA1|: true, if model is an SA1 afferents. Can be accessed, but not
% set.
% * |iRA|: true, if model is an RA afferent. Can be accessed, but not
% set.
% * |iPC|: true, if model is a PC afferent. Can be accessed, but not
% set.
%
% *Methods*
%
% <html>
% <ul><li><tt>a = AfferentPopulation(afflist)</tt>: Constructs an
% <tt>AfferentPopulation</tt> object.
% <ul><li><tt>afflist</tt> (optional): Vector of <tt>Afferent</tt> objects; 
% empty <tt>AfferentPopulation</tt> will be constructed if not supplied.</li></ul></li>
% <li><tt>aff_afferents(class,locs,varargin)</tt>:Generates specified
% Afferent objects and adds them to the AfferentPopulation.
% <ul><li><tt>class</tt>: Afferent class, needs to be 'SA1', 'RA', or
% 'PC'.</li>
% <li><tt>locs</tt>: Matrix containing location of each
% afferent.</li>
% <li><tt>varargin</tt>: Additional parameters passed to Afferent constructor, see
% above for details.</li></ul></li>
% <li><tt>r = response(stim,flag_distOnHand)</tt>:Calculate afferent population response
% to given stimulus, returns <tt>ResponseCollection</tt> object.
% <ul><li><tt>stim</tt>: Stimulus object.</li>
% <li><tt>flag_distOnHand</tt>: Determines whether wave propagation is calculated
% based on geometry of the hand model (if set to true), or based on absolute distance
% alone, ignoring gaps between fingers (if set to false), default false. Activating 
% this setting will increase computation time for wave propagation considerably, but
% this parameter is essential if the responses of afferents all over the hand are
% considered.</li></ul></li>
% <li><tt>plot(col_vec,varargin)</tt>: Generates a figure of the hand with the location
% of the afferent marked.
% <ul><li><tt>col_vec</tt>: Marker colors, default standard afferent colors (SA1: green, 
% RA: blue, PC: orange).</li>
% <li><tt>varargin</tt>: Additional parameters to be passed to <tt>plot_hand</tt>,
% as well as <tt>rate</tt>: adjusts transparency of colored marker based on response rate provided, 
% default no transparency.</li></ul></li></ul>
% </html>
%
% *Examples*

[x,y] = meshgrid(-5:5,-5:5);
a = AfferentPopulation();
a.add_afferents('RA',[x(:) y(:)]);
plot(a,[],'region','D2')

%% Stimulus
% Object that represents an arbitrary spatio-temporal tactile stimulus.
%
% *Properties*
%
% * |trace|: Matrix where each column refers to the indentation trace of a single pin (in
% mm, positive values indent into the skin), default
% |1+.5*sin(linspace(0,10,5000)*2*pi*10)'|. Changing the |trace| of a
% |Stimulus| object automatically triggers recomputation of the |profile|
% and |profiledyn| properties, which might be slow.
% * |location|: 2D matrix where each row denotes the position of one
% stimulus pin, default |[0 0]|. Changing the |location| of a
% |Stimulus| object automatically triggers recomputation of the |profile|
% and |profiledyn| properties, which might be slow.
% * |sampling_frequency|: Sampling frequency of |trace|, default 5000. Can
% be accessed, but only set through the |resample| and
% |update_sampling_frequency| methods, see below.
% * |duration|: Total duration of the stimulus in s, can be accessed but
% not set.
% * |pin_radius|: Radius for all pins in the current Stimulus object,
% default |0.05|. Can be accessed, but not set.
% * |profile|: Load profile calculated from trace, can be accessed but not
% set.
% * |profiledyn|: Dynamic load profile calculated from trace, can be
% accessed but not set.
%
% *Methods*
%
% <html>
% <ul><li><tt>s = Stimulus(trace,location,sampling_frequency,pin_radius)</tt>:
% Constructs a Stimulus object with the given parameters.
% % <ul><li><tt>trace</tt>: Indentation trace for each pin, see above.</li>
% <li><tt>location</tt>: Pin locations, see above.</li>
% <li><tt>sampling_frequency</tt>: Sampling frequency in Hz.</li>
% <li><tt>pin_radius</tt>: Pin radius, see above.</li></ul></li>
% <li><tt>resample(sampling_freq)</tt>: Resample the stimulus trace at the
% given frequency.
% <ul><li><tt>sampling_freq</tt>: New sampling frequency.</li></ul></li>
% <li><tt>update_sampling_frequency(sampling_freq)</tt>: Update sampling
% frequency, but keep current stimulus trace; this method is useful for
% quickly changing the speed of a stimulus (e.g. indenting or sliding
% across the skin) without having to recompute the stimulus profile again.
% <ul><li><tt>sampling_freq</tt>: New sampling frequency.</li></ul></li>
% <li><tt>pad(len1,len2)</tt>: Pad the stimulus trace with zeros. This
% method triggers a recomputation of the stimulus profiles.
% <ul><li><tt>len1</tt>: Length in s of leading padding. If a single value is given,
% the same padding is applied to all pins.</li>
% <li><tt>len2</tt>: Length in s of trailing padding. If a single value is given,
% the same padding is applied to all pins. If multiple values are given
% <tt>sum(len1+len2)</tt>
% needs to result in equal values for all pins. If no value is given and <tt>len1</tt> has one element,
% both leading and trailing padding will be the same; otherwise, if <tt>len1</tt> consists of multiple
% values, <tt>len2</tt> values will be chosen such that the trace for each pin will 
% have equal length.</li></ul></li>
% <li><tt>[s,stat_comp,dyn_comp] = propagate(aff,flag_distOnHand)</tt>:
% Propagates the stimulus to the given afferent(s). This method is
% automatically executed when calling <tt>Afferent.response</tt> or
% <tt>AfferentPopulation.response</tt> and needs to be called
% manually only if static or dynamic mechanics components need to be
% obtained explicitly.
% <ul><li><tt>aff</tt>: <tt>Afferent</tt> or <tt>AfferentPopulation</tt> objects.</li>
% <li><tt>flag_distOnHand</tt>: Determines whether wave propagation is calculated
% based on geometry of the hand model (if set to true), or based on absolute distance
% alone, ignoring gaps between fingers (if set to false), default false. Activating 
% this setting will increase computation time for wave propagation considerably, but
% this parameter is essential if the responses of afferents all over the hand are
% considered.</li>
% <li><tt>s</tt>: A Matlab <tt>struct</tt> containing <tt>stat_comp</tt>, <tt>dyn_comp</tt>, and
% <tt>sampling_frequency</tt>.</li>
% <li><tt>stat_comp</tt>: The static mechanical component.</li>
% <li><tt>dyn_comp</tt>: The dynamic mechanical component.</li></ul></li>
% <li><tt>compute_profile()</tt>: Recomputes the static and dynamic load
% profiles. This method is generally automatically triggered when there are
% changes to the object, so there is no need to call it manually.</li>
% <li><tt>plot()</tt>: Generates a figure showing the pin position(s) along with
% indentation profiles over time. The figure is interactive and allows selecting
% individual pins to visualize.</li>
% </ul>
% </html>
%
% *Examples*

trace = repmat(1+.5*sin(linspace(0,10,5000)*2*pi*10)',1,2);
s = Stimulus(trace+0.05*randn(size(trace)),[0 0; 1 1]);
s.duration

%%

figure
plot(s)

%% Response
% Object that represents the response of a single |Afferent| to a
% |Stimulus|.
%
% *Properties*
%
% * |afferent|: The |Afferent| object that is responding.
% * |propagated_struct|: The stimulus as experienced by the afferent, set
% to the output of |Stimulus.propagate|.
% * |spikes|: The vector of spike times.
% * |rate|: Firing rate of the afferent, calculated as the number of spikes
% divided by the stimulus duration. Can be accessed but not set.
% * |duration|: Stimulus/response duration. Can be accessed but not set.
%
% *Methods*
%
% <html>
% <ul><li><tt>r = Response(afferent,propagated_struct,spikes)</tt>:
% Constructs a <tt>Response</tt> object with the given parameters. Note that
% <tt>Response</tt> objects are generated by the <tt>Afferent.response</tt> function, so
% there is little need to create them manually.
% <ul><li><tt>afferent</tt>: The <tt>Afferent</tt> object that is responding.</li>
% <li><tt>propagated_struct</tt>: The stimulus as experienced by the afferent,
% returned by <tt>Stimulus.propagate</tt>.</li>
% <li><tt>sampling_frequency</tt>: Vector of spike times in s.</li></ul></li>
% <li><tt>psth = psth(bin_width)</tt>: Returns the PSTH of the afferent's
% response.
% <ul><li><tt>bin_width</tt>: Bin width in ms, default 10.</li></ul></li>
% <li><tt>plot(ax)</tt>: Plots a spike raster of the afferent's response.
% <ul><li><tt>ax</tt>: Figure axis to plot in, default new figure.</li></ul></li>
% </ul>
% </html>
%
% *Examples*

a = Afferent('SA1','idx',1);
s = stim_ramp();
r = a.response(s);
r.spikes

%%

r.rate

%%

figure
plot(r)


%% ResponseCollection
% Object that represents the response of an |AfferentPopulation| to a
% |Stimulus|.
%
% *Properties*
%
% * |affpop|: The |AfferentPopulation| object that is responding.
% * |stimulus|: The |Stimulus| object that the |AfferentPopulation is
% responding to.
% * |responses|: Vector of |Response| objects.
% * |rate|: Vector of firing rates of all afferents. Can be accessed but not set.
% * |duration|: Stimulus/response duration. Can be accessed but not set.
%
% *Methods*
%
% <html>
% <ul><li><tt>r = ResponseCollection(affpop,responses,stimulus</tt>:
% Constructs a <tt>ResponseCollection</tt> object with the given parameters. Note that
% <tt>ResponseCollection</tt> objects are generated by the <tt>AfferentPopulation.response</tt>
% function, so there is little need to create them manually.
% <ul><li><tt>affpop</tt>: The <tt>AfferentPopulation</tt> object that is responding.</li>
% <li><tt>responses</tt>: Vector of <tt>Response</tt> objects.</li>
% <li><tt>stimulus</tt>: The <tt>Stimulus</tt> object that the afferents are responding to.</li></ul></li>
% <li><tt>psth = psth(bin_width)</tt>: Returns a 2D matrix containing the
% PSTH of each afferent's response.
% <ul><li><tt>bin_width</tt>: Bin width in ms, default 10.</li></ul></li>
% <li><tt>plot(varargin)</tt>: Plots a spike raster of the population response.
% <ul><li><tt>varargin</tt>: Further parameters to be passed to <tt>plot_spikes</tt>.</li></ul></li>
% </ul>
% </html>
%
% *Examples*

a = affpop_single_models();
s = stim_ramp();
r = a.response(s);
r.rate

%%

figure
plot(r)
