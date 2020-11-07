function f_SLM_roi_save(app)

roi1 = f_SLM_roi_read(app);

idx1 = strcmpi(app.SelectROIDropDown.Value, [app.SLM_roi_list.name_tag]);
if sum(idx1)
    old_roi = app.SLM_roi_list(idx1);
    if ~isempty(old_roi.lut_correction_fname)
        idx = strcmpi(roi1.lut_correction_fname(1,1), old_roi.lut_correction_fname(:,1));
        if sum(idx)
            old_roi.lut_correction_fname(idx,:) = roi1.lut_correction_fname;
            roi1.lut_correction_fname = old_roi.lut_correction_fname;
        else
            roi1.lut_correction_fname = [roi1.lut_correction_fname; old_roi.lut_correction_fname];
        end
    end
    roi1.lut_correction_data = old_roi.lut_correction_data;
    
    app.SLM_roi_list(idx1) = roi1;
    app.SelectROIDropDown.Items = [app.SLM_roi_list.name_tag];
    app.SelectROIDropDown.Value = roi1.name_tag;
    app.GroupROIDropDown.Items = [app.SLM_roi_list.name_tag];
    app.SelectROIDropDownGH.Items = [app.SLM_roi_list.name_tag];
else
   disp('save did not work');
end

end