%% Fix .mat files that contain C library pointers (open this file and press Run)
% Files that warn on load ("C library object not loaded", "Object could not be
% loaded") are re-saved without the pointers. Each original is copied first to a
% backup_pointers\ subfolder next to it. Clean files are not touched.
%
% 1) Run once with dry_run = true  -> lists what would change, writes nothing
% 2) Set dry_run = false and run again -> fixes the listed files

%% settings
dry_run = false;

folders = {
    'C:\Users\ys2605\Desktop\stuff\SLM_GUI\SLM_calibration'
    % 'C:\Users\ys2605\Desktop\stuff\SLM_GUI\SLM_outputs'    % ~39 GB, slow: uncomment when ready
    };

%% paths (GUI classes must be on the path so saved SDK/ImageGen objects can be rebuilt)
this_dir = fileparts(mfilename('fullpath'));
gui_dir = fileparts(this_dir);
addpath(genpath(fullfile(gui_dir, 'SLM_GUI_funcions')));
addpath(this_dir);

%% run
warn_state = warning('off', 'backtrace');      % shorter warning lines
report = fix_mat_pointers(folders, dry_run);
warning(warn_state);

%% files that need attention
needs = report(~strcmp({report.status}, 'clean'));
if isempty(needs)
    disp('All files clean.');
else
    fprintf('\nFiles not clean:\n');
    for n = 1:numel(needs)
        fprintf('  %-12s %s\n', needs(n).status, needs(n).file);
    end
end
