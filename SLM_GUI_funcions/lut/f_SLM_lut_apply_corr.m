function pointer_out = f_SLM_lut_apply_corr(app, pointer, region)

idx_reg = strcmpi(region, [app.region_list.name_tag]);
if ~isempty(app.region_list(idx_reg).lut_correction)
    idx_lut_corr = strcmpi(app.region_list(idx_reg).lut_correction(:,1), app.SLM_ops.lut_fname);
    lut_corr_idx = strcmpi(app.lut_corrections_list(:,1), app.region_list(idx_reg).lut_correction{idx_lut_corr,2});
    lut_correction_data = app.lut_corrections_list{lut_corr_idx,2};
else
    lut_correction_data = [];
end

if ~isempty(lut_correction_data)
    pointer_out.Value = round(lut_correction_data(pointer.Value+1,2));
else
    pointer_out = pointer;
end

end