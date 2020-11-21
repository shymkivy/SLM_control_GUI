function f_SLM_lut_regional_load_list(app)

% load regional lut files
regional_lut_dir = [app.SLM_ops.lut_dir '\' app.SLM_ops.global_lut_fname(1:end-4) '_regional'];
[LUT_list, ~] = f_SLM_get_file_names(regional_lut_dir, '*.txt', 0);

LUT_list = [{'None'}; LUT_list];
app.lut_regional_list = LUT_list;
app.regionalLUTDropDown.Items = LUT_list;

% make folders for corrections for regional luts
for n_lut = 1:numel(LUT_list)
    if ~strcmpi(LUT_list{n_lut}, 'none')
        [~, fname, ~] = fileparts(LUT_list{n_lut});
        lut_corr_dir = [regional_lut_dir '\' fname '_correction'];
        if ~exist(lut_corr_dir, 'dir')
            mkdir(lut_corr_dir)
        end
    end
end

end