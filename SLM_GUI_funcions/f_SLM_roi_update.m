function f_SLM_roi_update(app)

indx1 = strcmpi([app.SLM_roi_list.name_tag],app.SelectROIDropDown.Value);
if sum(indx1)
    roi1 = app.SLM_roi_list(indx1);
    app.ROInameEditField.Value = roi1.name_tag{1};
    app.PixelfractionheightpixpixEditField.Value = [num2str(roi1.height_range(1)) ':' num2str(roi1.height_range(2))];
    app.PixelfractionwidthpixpixEditField.Value = [num2str(roi1.width_range(1)) ':' num2str(roi1.width_range(2))];
    app.WavelengthnmEditField_2.Value = roi1.wavelength;
    app.LUTfilereactivateSLMDropDown.Value = roi1.lut_fname;
else
    disp('ROI update failed')
end

end


