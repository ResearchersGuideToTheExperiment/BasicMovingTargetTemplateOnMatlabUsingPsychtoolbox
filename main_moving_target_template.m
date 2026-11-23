function results = main_moving_target_template(screenSizeCm, distanceCm)
% MAIN_MOVING_TARGET_TEMPLATE Run a generic demonstration; results remain in memory.
% Supply measured active screen [width height] in cm and eye distance in cm.
% Example only: results = main_moving_target_template([50 30], 60);
if nargin ~= 2
    error('Supply measured screen size [width height] cm and viewing distance cm.');
end
root = fileparts(mfilename('fullpath'));
oldPath = path;
pathGuard = onCleanup(@() path(oldPath)); %#ok<NASGU>
addpath(fullfile(root,'functions'));
% Validate calibration before opening the display.
create_geometry([1 1],screenSizeCm,distanceCm);
assert(exist('Screen','file') ~= 0, 'Install Psychtoolbox separately first.');
oldSync = Screen('Preference','SkipSyncTests',0);
displayGuard = onCleanup(@() cleanup_display(oldSync)); %#ok<NASGU>
[window,g,ifi] = open_display(screenSizeCm,distanceCm);
sigmaDeg = 0.35; % Gaussian standard deviation; support extends to +/-4 sigma.
seed = 1; % Reproducible demonstration, without modifying the caller's RNG state.
oldRng = rng; rngGuard = onCleanup(@() rng(oldRng)); %#ok<NASGU>
rng(seed,'twister');
results = struct('geometry',g,'refreshIntervalSec',ifi,'seed',seed,'sigmaDeg',sigmaDeg);
Screen('TextSize',window,24);
DrawFormattedText(window, 'Observe the moving target.\n\nPress SPACE to start. ESC to stop.', ...
    'center','center',0);
Screen('Flip',window);
wait_for_space;
% Each row is [startX startY finishX finishY], in angular coordinates.
routes = [-4 2 4 2; 4 -2 -4 -2];
routes = routes(randperm(size(routes,1)),:);
for trial = 1:size(routes,1)
    results.trials(trial).motion = present_motion(window,g,ifi, ...
        routes(trial,1:2),routes(trial,3:4),2,sigmaDeg);
    wait_seconds(0.5);
end
end
