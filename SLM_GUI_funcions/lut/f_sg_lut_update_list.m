function f_sg_lut_update_list(app)

% update global and list
f_sg_lut_load_list(app);
app.SLM_ops.lut_fname = app.LUTDropDown.Value;

% update regional if necessary
if app.SLM_ops.SDK_created == 1
    f_SLM_update_lut(app.SLM_ops);
end

f_sg_lut_correctios_load_list(app);

% first check if files exist
for n_reg = 1:numel(app.region_obj_params)
    temp_fname = app.region_obj_params(n_reg).lut_correction_fname;
    temp_list = app.lut_corrections_list(:,1);
    if ~isempty(temp_fname)
        if ~sum(strcmpi(temp_fname, temp_list))
            app.region_obj_params(n_reg).lut_correction_fname = [];
        end
    end
end

for n_reg = 1:numel(app.region_obj_params)
    app.region_obj_params(n_reg).lut_correction_data = f_sg_get_corr_data(app, app.region_obj_params(n_reg).lut_correction_fname);
end

f_sg_reg_update(app);

end