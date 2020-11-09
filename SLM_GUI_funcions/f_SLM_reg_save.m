function f_SLM_reg_save(app)

reg1 = f_SLM_reg_read(app);

idx1 = strcmpi(app.SelectRegionDropDown.Value, [app.region_list.name_tag]);
if sum(idx1)
    old_reg = app.region_list(idx1);
    if ~isempty(old_reg.lut_correction)
        idx = strcmpi(reg1.lut_correction(1,1), old_reg.lut_correction(:,1));
        if sum(idx)
            old_reg.lut_correction(idx,:) = reg1.lut_correction;
            reg1.lut_correction = old_reg.lut_correction;
        else
            reg1.lut_correction = [reg1.lut_correction; old_reg.lut_correction];
        end
    end
    app.region_list(idx1) = reg1;
    app.SelectRegionDropDown.Items = [app.region_list.name_tag];
    app.SelectRegionDropDown.Value = reg1.name_tag;
    app.GroupRegionDropDown.Items = [app.region_list.name_tag];
    app.SelectRegionDropDownGH.Items = [app.region_list.name_tag];
else
   disp('save did not work');
end

end