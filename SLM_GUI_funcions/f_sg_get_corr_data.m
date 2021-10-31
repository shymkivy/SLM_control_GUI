function lut_correction = f_sg_get_corr_data(app, lut_corr_fname)

% get reg
if ~exist('lut_corr_fname', 'var')
    [~, ~, reg1] = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);
    idx_reg = strcmpi(reg1.reg_name, [app.region_list.reg_name]);
    lut_corr_fname = app.region_list(idx_reg).lut_correction_fname;
end

if ~isempty(lut_corr_fname)
    idx_lut_corr = strcmpi(lut_corr_fname(:,1), app.SLM_ops.lut_fname);
    lut_corr_idx = strcmpi(app.lut_corrections_list(:,1), lut_corr_fname{idx_lut_corr,2});
    lut_correction = app.lut_corrections_list{lut_corr_idx,2}.lut_corr;
else
    lut_correction = [];
end

end