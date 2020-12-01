function f_SLM_reg_add(app)

reg1 = f_SLM_reg_read(app);

idx1 = strcmpi(app.RegionnameEditField.Value, [app.region_list.name_tag]);
if sum(idx1)
    disp('Region name already exists');
else
    app.region_list = [app.region_list; reg1];
    app.SelectRegionDropDown.Items = [app.region_list.name_tag];
    app.SelectRegionDropDown.Value = reg1.name_tag;
    app.GroupRegionDropDown.Items = [app.region_list.name_tag];
    app.SelectRegionDropDownGH.Items = [app.region_list.name_tag];
    app.AOregionDropDown.Items = [app.region_list.name_tag];
end

end