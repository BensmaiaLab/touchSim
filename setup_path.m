p = mfilename('fullpath');
p = fileparts(p);

addpath([p '/base/model'])              % base model code
addpath([p '/base/internal'])           % internal functions
addpath([p '/base/GUI'])                % GUI
addpath([p '/base/skinmech/'])          % Skin mechanics code
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
