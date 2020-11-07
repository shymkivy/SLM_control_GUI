function f_SLM_roi_update(app)

indx1 = strcmpi([app.SLM_roi_list.name_tag],app.SelectROIDropDown.Value);
if sum(indx1)
    roi1 = app.SLM_roi_list(indx1);
    app.ROInameEditField.Value = roi1.name_tag{1};
    app.ROIheightminEditField.Value = roi1.height_range(1);
    app.ROIheightmaxEditField.Value = roi1.height_range(2);
    app.ROIwidthminEditField.Value = roi1.width_range(1);
    app.ROIwidthmaxEditField.Value = roi1.width_range(2);
    app.ROIWavelengthnmEditField.Value = roi1.wavelength;
    
    % update dropdown
    ops = app.SLM_ops;
    lut_correction_dir = [ops.GUI_dir, '\' ops.lut_dir '\' ops.lut_fname(1:end-4) '_correction\' ];
    dir1 = dir([lut_correction_dir '\*.mat']);
    dirnames = {dir1.name}';
    if ~isempty(dirnames)
        app.ROILUTcorrectionDropDown.Items = dirnames;
        if ~isempty(roi1.lut_correction_fname)
            lut_idx = strcmpi(roi1.lut_correction_fname(:,1), ops.lut_fname);
            lut_corr_list = roi1.lut_correction_fname(lut_idx,2);
            lut_corr_idx = strcmpi(lut_corr_list, dirnames);
            if sum(lut_corr_idx)
                app.ROILUTcorrectionDropDown.Value = lut_corr_list;
            else
                app.ROILUTcorrectionDropDown.Value = dirnames(1);
            end
        end
    else
        app.ROILUTcorrectionDropDown.Items = {''};
    end
    
    % update lut correction data
    if ~isempty(app.ROILUTcorrectionDropDown.Value)
        lut_corr_data = load([lut_correction_dir app.ROILUTcorrectionDropDown.Value]);
        app.SLM_roi_list(indx1).lut_correction_data = lut_corr_data.LUT_correction;
    else
        app.SLM_roi_list(indx1).lut_correction_data = [];
    end
else
    disp('ROI update failed')
end

end


