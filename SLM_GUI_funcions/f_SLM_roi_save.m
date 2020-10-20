function f_SLM_roi_save(app)

roi1 = f_SLM_roi_read(app);

idx1 = strcmpi(app.SelectROIDropDown.Value, [app.SLM_roi_list.name_tag]);
if sum(idx1)
    app.SLM_roi_list(idx1) = roi1;
    app.SelectROIDropDown.Items = [app.SLM_roi_list.name_tag];
    app.SelectROIDropDown.Value = roi1.name_tag;
    app.GroupROIDropDown.Items = [app.SLM_roi_list.name_tag];
    app.SelectROIDropDownGH.Items = [app.SLM_roi_list.name_tag];
else
   disp('save did not work');
end

end