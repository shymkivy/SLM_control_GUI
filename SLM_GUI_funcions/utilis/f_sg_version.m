function [ver_str, info] = f_sg_version()
% SLM GUI version. Bump VERSION on releases.
% ver_str = 'v1.0.0' (window title). info.full = 'v1.0.0 (a3cc256, 2026-11-03)' adds the
% git commit + date ('+' = uncommitted changes); without git on the PATH it equals ver_str.

VERSION = '1.0.0';

info = struct('version', VERSION, 'commit', '', 'date', '', 'dirty', false, 'full', '');
gui_dir = fileparts(fileparts(fileparts(mfilename('fullpath'))));   % utilis -> SLM_GUI_funcions -> SLM_GUI

[st, out] = system(sprintf('git -C "%s" log -1 --format="%%h %%ad" --date=short', gui_dir));
if st == 0
    parts = strsplit(strtrim(out));
    if numel(parts) == 2
        info.commit = parts{1};
        info.date = parts{2};
        [st2, out2] = system(sprintf('git -C "%s" status --porcelain --untracked-files=no', gui_dir));
        info.dirty = st2 == 0 && ~isempty(strtrim(out2));
    end
end

ver_str = sprintf('v%s', VERSION);
info.full = ver_str;
if ~isempty(info.commit)
    dirty_tag = '';
    if info.dirty; dirty_tag = '+'; end
    info.full = sprintf('%s (%s%s, %s)', ver_str, info.commit, dirty_tag, info.date);
end
end
