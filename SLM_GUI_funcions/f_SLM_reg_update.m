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
    global_lut = {app.globalLUTDropDown.Value};
    regional_lut = {app.regionalLUTDropDown.Value};
    
    lut_corr = {'None'};
    % load saved correction value
    if isfield(reg1, 'lut_correction')
        if ~isempty(reg1.lut_correction)
            save_idx = strcmpi(global_lut, reg1.lut_correction(:,1)).*strcmpi(regional_lut, reg1.lut_correction(:,2));
            if sum(save_idx)
                lut_corr = reg1.lut_correction(save_idx,3);
            end
        end
    end
    
    app.LUTcorrectionDropDown.Items = app.lut_corrections_list(:,1);
    app.LUTcorrectionDropDown.Value = lut_corr;
else
    disp('Region update failed')
end

end


