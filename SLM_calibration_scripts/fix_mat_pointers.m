function report = fix_mat_pointers(folders, dry_run)
% Re-save .mat files that contain C library pointers (libpointer) or stale
% objects, so they load without warnings in newer MATLAB.
%
%   fix_mat_pointers(folder)              % fix every .mat under folder (recursive)
%   fix_mat_pointers({f1, f2})            % several folders
%   fix_mat_pointers(folder, true)        % dry run: only list files that would change
%
% Only files that warn on load are rewritten. Each one is copied first to
% <its folder>\backup_pointers\ (an existing backup is never overwritten).
% Same variable names and the same MAT format (v7 or v7.3) are kept.
% Pointer values (which can't be restored) become [] — all other data is unchanged.
% Run with the SLM_GUI folders on the path, so saved SDK/ImageGen objects can be rebuilt.

if nargin < 2; dry_run = false; end
if ischar(folders) || isstring(folders); folders = cellstr(folders); end

report = struct('file', {}, 'status', {}, 'warning', {});
for n_f = 1:numel(folders)
    files = dir(fullfile(folders{n_f}, '**', '*.mat'));
    for n = 1:numel(files)
        if contains(files(n).folder, 'backup')
            continue;
        end
        p = fullfile(files(n).folder, files(n).name);
        report(end+1).file = p; %#ok<AGROW>

        lastwarn('');
        try
            s = load(p);
        catch err
            report(end).status = 'load failed';
            report(end).warning = err.message;
            fprintf('LOAD FAILED  %s\n   %s\n', p, err.message);
            continue;
        end
        msg = lastwarn;
        if isempty(msg)
            report(end).status = 'clean';
            continue;
        end
        report(end).warning = msg;

        if dry_run
            report(end).status = 'would fix';
            fprintf('WOULD FIX    %s\n   (%s)\n', p, msg);
            continue;
        end

        bdir = fullfile(files(n).folder, 'backup_pointers');
        if ~exist(bdir, 'dir'); mkdir(bdir); end
        bfile = fullfile(bdir, files(n).name);
        if ~exist(bfile, 'file')
            copyfile(p, bfile);
        end

        if is_v73(p)
            save(p, '-struct', 's', '-v7.3');
        else
            save(p, '-struct', 's');
        end

        clear s
        lastwarn('');
        s = load(p);                     % reload to confirm it is clean now
        clear s
        if isempty(lastwarn)
            report(end).status = 'fixed';
            fprintf('FIXED        %s\n', p);
        else
            report(end).status = 'still warns';
            fprintf('STILL WARNS  %s\n   (%s)\n', p, lastwarn);
        end
    end
end

statuses = {report.status};
fprintf('\n%d files: %d clean, %d fixed, %d would fix, %d still warn, %d failed\n', numel(report), ...
    sum(strcmp(statuses, 'clean')), sum(strcmp(statuses, 'fixed')), sum(strcmp(statuses, 'would fix')), ...
    sum(strcmp(statuses, 'still warns')), sum(strcmp(statuses, 'load failed')));
end

function tf = is_v73(p)
fid = fopen(p, 'r');
head = fread(fid, 128, '*char')';
fclose(fid);
tf = contains(head, 'MATLAB 7.3');
end
