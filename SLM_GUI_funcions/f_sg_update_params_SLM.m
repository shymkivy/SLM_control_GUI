function f_sg_update_params_SLM(app)

was_on = app.SLM_ops.SDK_created;

if app.SLM_ops.SDK_created
    app.SLM_ops = f_SLM_close(app.SLM_ops);
    if ~app.SLM_ops.SDK_created
        app.ActivateSLMLamp.Color = [0.80,0.80,0.80]; %[0.00,1.00,0.00];
        app.ActivateSLMButton.Value = 0;
    end
end

app.SLM_ops.SLM_type = app.SLMtypeDropDown.Value;

%%
SLM_params = app.SLM_ops.SLM_params(strcmpi({app.SLM_ops.SLM_params.SLM_name}, app.SLM_ops.SLM_type));
app.SLM_ops = f_copy_fields(app.SLM_ops, SLM_params);

%%
f_sg_lut_load_list(app);

% update from default
if isfield(SLM_params, 'lut_fname')
    if sum(strcmpi(SLM_params.lut_fname, app.LUTDropDown.Items))
        app.LUTDropDown.Value = SLM_params.lut_fname;
    end
else
    if sum(strcmpi('linear.lut', app.LUTDropDown.Items))
        SLM_params.lut_fname = 'linear.lut';
        app.SLM_ops.lut_fname = 'linear.lut';
        app.LUTDropDown.Value = SLM_params.lut_fname;
    end
end

%%
if was_on
    app.SLM_ops = f_SLM_initialize(app.SLM_ops);
    if app.SLM_ops.SDK_created
        app.ActivateSLMLamp.Color = [0.00,1.00,0.00];
        app.ActivateSLMButton.Value = 1;
    end
end

%%
region_list = app.SLM_ops.default_region_list;
if isfield(app.SLM_ops, 'region_list')
    if ~isempty(app.SLM_ops.region_list)
        region_list = app.SLM_ops.region_list;
    end
end

if isfield(SLM_params, 'regions_use')
    if ~isempty(SLM_params.regions_use)
        is_reg = false(numel(region_list),1);
        for n_reg = 1:numel(region_list)
            is_reg(n_reg) = sum(strcmpi(region_list(n_reg).reg_name, SLM_params.regions_use));
        end
        region_list(~is_reg) = [];
    end
end

if isempty(region_list)
    region_list = default_region_list;
end

app.region_list = region_list;
app.SelectRegionDropDown.Items = {region_list.reg_name};
app.CurrentregionDropDown.Items = {region_list.reg_name};

%%
f_sg_load_calibration(app);
f_sg_reg_update(app);

end