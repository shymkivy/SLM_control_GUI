function region1 = f_SLM_reg_read(app)
%%

region1.name_tag = {app.RegionnameEditField.Value};
region1.height_range = [app.regionheightminEditField.Value, app.regionheightmaxEditField.Value];
region1.width_range = [app.regionwidthminEditField.Value, app.regionwidthmaxEditField.Value];
region1.wavelength = app.regionWavelengthnmEditField.Value;
if ~strcmpi(app.regionLUTcorrectionDropDown.Value, 'none')
    path1 = [app.SLM_ops.GUI_dir '\' app.SLM_ops.lut_dir '\' app.SLM_ops.lut_fname(1:end-4) '_correction\' app.regionLUTcorrectionDropDown.Value];
    data1 = load(path1);
    LUT_correction = data1.LUT_correction;
else
    LUT_correction = {[]};
end
region1.lut_correction = [{app.SLM_ops.lut_fname}, {app.regionLUTcorrectionDropDown.Value}, LUT_correction];
end