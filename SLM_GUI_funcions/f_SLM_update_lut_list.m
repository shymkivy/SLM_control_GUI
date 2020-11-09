function f_SLM_update_lut_list(app)

[LUT_list, ~] = f_SLM_get_file_names(app.SLM_ops.lut_dir, '*.lut', 0);
app.global_LUT_list = cell(numel(LUT_list),2);
app.global_LUT_list(:,1) = LUT_list;
for n_lut = 1:numel(LUT_list)
    [~, fname, ~] = fileparts(LUT_list{n_lut});
    lut_corr_dir = [app.SLM_ops.GUI_dir '\' app.SLM_ops.lut_dir '\' fname '_correction'];
    if ~exist(lut_corr_dir, 'dir')
        mkdir(lut_corr_dir)
    else
        [lut_corr, ~] = f_SLM_get_file_names(lut_corr_dir, '*.mat', 0);
        app.global_LUT_list{n_lut,2} = lut_corr;
    end
end
app.globalLUTreactivateSLMDropDown.Items = LUT_list;

for n_reg = 1:numel([app.region_list.name_tag])
    if ~isfield(app.region_list(n_reg), 'lut_correction')
        app.region_list(n_reg).lut_correction = [];
    end
    for n_lut = 1:size(app.global_LUT_list,1)
        if isempty(app.region_list(n_reg).lut_correction)
            lut_correction = [app.global_LUT_list(n_lut,1), {'none'}, {[]}];
            app.region_list(n_reg).lut_correction = lut_correction;
        end
        lut_idx = strcmpi(app.global_LUT_list(n_lut,1), app.region_list(n_reg).lut_correction(:,1));
        if ~sum(lut_idx)
            lut_correction = [app.global_LUT_list(n_lut,1), {'none'}, {[]}];
            app.region_list(n_reg).lut_correction = [app.region_list(n_reg).lut_correction; lut_correction];
        end
    end
end

end