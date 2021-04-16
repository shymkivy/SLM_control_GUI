function f_sg_lut_load_list(app)

% load global lut files
[LUT_list, ~] = f_sg_get_file_names(app.SLM_ops.lut_dir, '*.lut', 0);
[LUT_list2, ~] = f_sg_get_file_names(app.SLM_ops.lut_dir, '*.txt', 0);

LUT_list = [LUT_list; LUT_list2];

app.lut_list = LUT_list;
app.LUTDropDown.Items = LUT_list;

% create folders for regional lut and corrections
for n_lut = 1:numel(LUT_list)
    [~, fname, ~] = fileparts(LUT_list{n_lut});
    lut_corr_dir = [app.SLM_ops.lut_dir '\' fname '_correction'];
    if ~exist(lut_corr_dir, 'dir')
        mkdir(lut_corr_dir)
    end
end

end