function region1 = f_sg_reg_read(app)
%%
region1.reg_name = {app.RegionnameEditField.Value};
region1.height_range = [app.regionheightminEditField.Value, app.regionheightmaxEditField.Value];
region1.width_range = [app.regionwidthminEditField.Value, app.regionwidthmaxEditField.Value];
region1.wavelength = app.regionWavelengthnmEditField.Value;
region1.effective_NA = app.regionEffectiveNAEditField.Value;
region1.beam_diameter = app.regionBeamDiameterEditField.Value;
if strcmpi(app.LUTcorrectionDropDown.Value, 'none')
    region1.lut_correction_fname = [];
else
    region1.lut_correction_fname = [{app.LUTDropDown.Value}, {app.LUTcorrectionDropDown.Value}];
end

region1.lut_correction_data = f_sg_get_corr_data(app, region1.lut_correction_fname);

if strcmpi(app.XYZaffinetransformDropDown.Value, 'none')
    region1.xyz_affine_tf_fname = [];
else
    region1.xyz_affine_tf_fname = app.XYZaffinetransformDropDown.Value;
end

if strcmpi(app.AOcorrectionDropDown.Value, 'none')
    region1.AO_correction_fname = [];
else
    region1.AO_correction_fname = app.AOcorrectionDropDown.Value;
end

region1.xyz_affine_tf_mat = f_sg_compute_xyz_affine_tf_mat_reg(app, region1);

region1.AO_wf = f_sg_AO_compute_wf(app, region1);

end