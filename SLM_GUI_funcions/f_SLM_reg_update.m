function f_SLM_reg_update(app)

indx1 = strcmpi([app.region_list.name_tag],app.SelectRegionDropDown.Value);
if sum(indx1)
    reg1 = app.region_list(indx1);
    app.RegionnameEditField.Value = reg1.name_tag{1};
    app.regionheightminEditField.Value = reg1.height_range(1);
    app.regionheightmaxEditField.Value = reg1.height_range(2);
    app.regionwidthminEditField.Value = reg1.width_range(1);
    app.regionwidthmaxEditField.Value = reg1.width_range(2);
    app.regionWavelengthnmEditField.Value = reg1.wavelength;
    
    % update dropdown
    current_lut = {app.globalLUTreactivateSLMDropDown.Value};
    
    glob_lut_idx = strcmpi(app.global_LUT_list(:,1), current_lut);
    lut_corr = [{'none'}; app.global_LUT_list{glob_lut_idx,2}];
    app.regionLUTcorrectionDropDown.Items = lut_corr;
    
    lut_corr_idx = strcmpi(current_lut, reg1.lut_correction(:,1));
    app.regionLUTcorrectionDropDown.Value = reg1.lut_correction(lut_corr_idx,2);
else
    disp('Region update failed')
end

end


