p = mfilename('fullpath');
p = fileparts(p);

addpath([p '/src/model'])              % base model code
addpath([p '/src/internal'])           % internal functions
addpath([p '/src/GUI'])                % GUI
addpath([p '/src/skinmech/'])          % Skin mechanics code
addpath([p '/docs'])                    % Toolbox documentation

% optional directories
if exist([p '/tests'],'dir')
    addpath([p '/tests'])               % test scripts & helper functions
    addpath([p '/tests/helper_functions'])
end
if exist([p '/fitting'],'dir')
    addpath([p '/fitting'])             % model fitting code
end
if exist([p '/fitting/mat'],'dir')
    addpath([p '/fitting/mat'])         % model fitting data
end

clear p
