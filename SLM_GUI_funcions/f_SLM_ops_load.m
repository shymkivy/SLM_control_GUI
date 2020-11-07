function f_SLM_ops_load(app)

fname = 'SLM_GUI_local_ops.mat';

if exist(fname, 'file')
    load_data = load(fname, 'saved_data');
    load_data = load_data.saved_data;

    app.SLM_roi_list = load_data.SLM_roi_list;
    app.xyz_patterns = load_data.xyz_patterns;

    f_SLM_roi_update(app);
    f_SLM_pat_update(app);
end

end