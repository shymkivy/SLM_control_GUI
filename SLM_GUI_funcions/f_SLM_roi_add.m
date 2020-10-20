function f_SLM_roi_add(app)

roi1 = f_SLM_roi_read(app);

idx1 = strcmpi(app.ROInameEditField.Value, [app.SLM_roi_list.name_tag]);
if sum(idx1)
    disp('ROI name already exists');
else
    app.SLM_roi_list = [app.SLM_roi_list; roi1];
    app.SelectROIDropDown.Items = [app.SLM_roi_list.name_tag];
    app.SelectROIDropDown.Value = roi1.name_tag;
    app.GroupROIDropDown.Items = [app.SLM_roi_list.name_tag];
    app.SelectROIDropDownGH.Items = [app.SLM_roi_list.name_tag];
end

end