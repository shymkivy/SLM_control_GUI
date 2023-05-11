function f_sg_AO_fit_corrections(app)

reg1 = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);

ao_data = reg1.AO_wf.AO_data;

%%
AO_correction_all = cat(1,ao_data.AO_correction);
max_modes = max(AO_correction_all(:,1));

if isempty(app.modestofitEditField.Value)
    modes_to_fit = 1:max_modes;
else
    modes_to_fit = f_str_to_array(app.modestofitEditField.Value)';
end
%%
fit_params.fit_type = app.FitmethodDropDown.Value;
fit_params.spline_smoothing_param = app.splinesmparam01EditField.Value;
fit_params.constrain_z0 = app.Constrainz0CheckBox.Value;
fit_params.ignore_zeros = app.Ignore0CheckBox.Value;
fit_params.plot_corr = app.PlotfitCheckBox.Value;
fit_params.plot_extra = app.PlotextraCheckBox.Value;
AO_correction = f_sg_AO_do_zernike_fit(ao_data, modes_to_fit, fit_params);

if app.save_fit_weightsCheckBox.Value
    reg1.AO_wf.fit_weights = AO_correction.fit_weights;
    reg1.AO_wf.fit_eq = AO_correction.fit_eq;
    reg1.AO_wf.fit_fx = AO_correction.fit_fx;
    
    maxZn = ceil((-1 + sqrt(1 + 4*max_modes*2))/2)-1;
    zernike_nm_all = f_sg_get_zernike_mode_nm(0:maxZn);
    reg1.AO_wf.all_modes = f_sg_gen_zernike_modes(reg1, zernike_nm_all);

    reg_params_idx = f_sg_get_reg_params_idx(app, app.CurrentregionDropDown.Value);
    app.region_obj_params(reg_params_idx).AO_wf = reg1.AO_wf;
    disp('saved fit')
end
end