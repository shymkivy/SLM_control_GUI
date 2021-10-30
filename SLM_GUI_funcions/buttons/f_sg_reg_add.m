function f_sg_reg_add(app)

reg1 = f_sg_reg_read(app);

idx1 = strcmpi(app.RegionnameEditField.Value, [app.region_list.reg_name]);
if sum(idx1)
    disp('Region name already exists');
else
    app.region_list = [app.region_list; reg1];
    app.SelectRegionDropDown.Items = [app.region_list.reg_name];
    app.SelectRegionDropDown.Value = reg1.reg_name;
    app.CurrentregionDropDown.Items = [app.region_list.reg_name];
end

end