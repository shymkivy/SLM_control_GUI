function region1 = f_SLM_reg_read(app)
%%
region1.name_tag = {app.RegionnameEditField.Value};
region1.height_range = [app.regionheightminEditField.Value, app.regionheightmaxEditField.Value];
region1.width_range = [app.regionwidthminEditField.Value, app.regionwidthmaxEditField.Value];
region1.wavelength = app.regionWavelengthnmEditField.Value;
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
if strcmpi(app.AxialcalibrationDropDown.Value, 'none')
    region1.axial_calibration = [];
else
    region1.axial_calibration = app.AxialcalibrationDropDown.Value;
end

end