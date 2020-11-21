function f_SLM_lut_global_load_list(app)

% load global lut files
[LUT_list, ~] = f_SLM_get_file_names(app.SLM_ops.lut_dir, '*.lut', 0);
app.lut_global_list = LUT_list;
app.globalLUTDropDown.Items = LUT_list;

% create folders for regional lut and corrections
for n_lut = 1:numel(LUT_list)
    [~, fname, ~] = fileparts(LUT_list{n_lut});
    lut_corr_dir = [app.SLM_ops.lut_dir '\' fname '_regional'];
    if ~exist(lut_corr_dir, 'dir')
        mkdir(lut_corr_dir)
    end
end

end