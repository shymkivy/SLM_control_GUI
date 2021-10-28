function f_sg_reg_update(app)

indx1 = strcmpi([app.region_list.name_tag],app.SelectRegionDropDown.Value);
if sum(indx1)
    reg1 = app.region_list(indx1);
    app.RegionnameEditField.Value = reg1.name_tag{1};
    app.regionheightminEditField.Value = reg1.height_range(1);
    app.regionheightmaxEditField.Value = reg1.height_range(2);
    app.regionwidthminEditField.Value = reg1.width_range(1);
    app.regionwidthmaxEditField.Value = reg1.width_range(2);
    app.regionWavelengthnmEditField.Value = reg1.wavelength;
    app.regionEffectiveNAEditField.Value = reg1.effective_NA;
    
    % update dropdown
    lut_fname = {app.LUTDropDown.Value};
    lut_corr_fname = {'None'};
    
    % load saved correction value
    if isfield(reg1, 'lut_correction_fname')
        if ~isempty(reg1.lut_correction_fname)
            save_idx = strcmpi(lut_fname, reg1.lut_correction_fname(:,1));
            if sum(save_idx)
                lut_corr_fname = reg1.lut_correction_fname(save_idx,2);
            end
        end
    end
    
    app.LUTcorrectionDropDown.Items = app.lut_corrections_list(:,1);
    app.LUTcorrectionDropDown.Value = lut_corr_fname;
    
    if isempty(reg1.lateral_affine_transform)
        app.LateralaffinetransformDropDown.Value = {'None'};
    else
        app.LateralaffinetransformDropDown.Value = reg1.lateral_affine_transform;
    end

    if isempty(reg1.AO_correction)
        app.AOcorrectionDropDown.Value = {'None'};
    else
        app.AOcorrectionDropDown.Value = reg1.AO_correction;
    end
    
else
    disp('Region update failed')
end

end


