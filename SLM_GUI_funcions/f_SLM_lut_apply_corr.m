function pointer_out = f_SLM_lut_apply_corr(app, pointer, region)

idx_reg = strcmpi(region, [app.region_list.name_tag]);
idx_lut_corr = strcmpi(app.region_list(idx_reg).lut_correction(:,1), app.SLM_ops.global_lut_fname);

lut_correction_data = app.region_list(idx_reg).lut_correction{idx_lut_corr,3};

if ~isempty(lut_correction_data)
    pointer_out.Value = round(lut_correction_data(pointer.Value+1,2));
else
    pointer_out = pointer;
end

end