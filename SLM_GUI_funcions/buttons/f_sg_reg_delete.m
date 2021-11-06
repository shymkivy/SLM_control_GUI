function f_sg_reg_delete(app)

idx1 = strcmpi(app.SelectRegionDropDown.Value, {app.region_list.reg_name});

if sum(idx1)
    app.region_list(idx1) = [];
    app.SelectRegionDropDown.Items(idx1) = [];
    f_sg_reg_update(app);
    app.SelectRegionDropDown.Items = {app.region_list.reg_name};
    app.CurrentregionDropDown.Items = {app.region_list.reg_name};
else
    disp('Delete did not work')
end

end