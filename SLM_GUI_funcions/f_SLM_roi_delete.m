function f_SLM_roi_delete(app)

idx1 = strcmpi(app.SelectROIDropDown.Value, [app.SLM_roi_list.name_tag]);
if sum(idx1)
    app.SLM_roi_list(idx1) = [];
    app.SelectROIDropDown.Items(idx1) = [];
    f_SLM_roi_update(app);
    app.GroupROIDropDown.Items = [app.SLM_roi_list.name_tag];
    app.SelectROIDropDownGH.Items = [app.SLM_roi_list.name_tag];
else
    disp('Delete did not work')
end


end