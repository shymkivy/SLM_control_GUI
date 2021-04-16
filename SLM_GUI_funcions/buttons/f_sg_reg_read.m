function region1 = f_sg_reg_read(app)
%%
region1.name_tag = {app.RegionnameEditField.Value};
region1.height_range = [app.regionheightminEditField.Value, app.regionheightmaxEditField.Value];
region1.width_range = [app.regionwidthminEditField.Value, app.regionwidthmaxEditField.Value];
region1.wavelength = app.regionWavelengthnmEditField.Value;
region1.effective_NA = app.regionEffectiveNAEditField.Value;
if strcmpi(app.LUTcorrectionDropDown.Value, 'none')
    region1.lut_correction = [];
else
    region1.lut_correction = [{app.LUTDropDown.Value}, {app.LUTcorrectionDropDown.Value}];
end

if strcmpi(app.LateralaffinetransformDropDown.Value, 'none')
    region1.lateral_affine_transform = [];
else
    region1.lateral_affine_transform = app.LateralaffinetransformDropDown.Value;
end

if strcmpi(app.AOcorrectionDropDown.Value, 'none')
    region1.AO_correction = [];
else
    region1.AO_correction = app.AOcorrectionDropDown.Value;
end

region1.xyz_affine_tf_mat = f_sg_compute_xyz_affine_tf_mat_reg(app, region1);

region1.AO_wf = f_sg_AO_compute_wf2(app, region1);

end