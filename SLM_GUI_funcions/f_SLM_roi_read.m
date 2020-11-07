function roi1 = f_SLM_roi_read(app)
%%

roi1.name_tag = {app.ROInameEditField.Value};
roi1.height_range = [app.ROIheightminEditField.Value, app.ROIheightmaxEditField.Value];
roi1.width_range = [app.ROIwidthminEditField.Value, app.ROIwidthmaxEditField.Value];
roi1.wavelength = app.ROIWavelengthnmEditField.Value;
roi1.lut_correction_fname = [{app.SLM_ops.lut_fname}, {app.ROILUTcorrectionDropDown.Value}];

end