function roi1 = f_SLM_roi_read(app)
%%
roi1.name_tag = {app.ROInameEditField.Value};
%%
height_range = str2double(split(app.PixelfractionheightpixpixEditField.Value, ':'));
if height_range(2) < 1
    height_range = height_range*app.SLM_ops.height;
end
roi1.height_range = [max([1 height_range(1)]) min([app.SLM_ops.height height_range(2)])];
%%
width_range = str2double(split(app.PixelfractionwidthpixpixEditField.Value, ':'));
if width_range(2) < 1
    width_range = width_range*app.SLM_ops.width;
end
roi1.width_range = [max([1 width_range(1)]) min([app.SLM_ops.width width_range(2)])];
%%
roi1.wavelength = app.WavelengthnmEditField_2.Value;

roi1.lut_fname = app.LUTconversionfileDropDown.Value;

%roi1.lut_fname = app.LutfileDropDown.Value;

end