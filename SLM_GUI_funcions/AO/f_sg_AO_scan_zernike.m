function f_sg_AO_scan_zernike(app)

if app.ScanZernikeButton.Value
    init_phase_corr_lut = app.SLM_phase_corr_lut;
    try
        disp('Initializing Zernike Scan...')
        time_stamp = clock;
        
        %% create AO file
        [~, ~, reg1] = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);
        coord = app.current_SLM_coord;
        
        AO_phase = f_sg_AO_get_z_corrections(app, reg1, coord.xyzp(:,3));
            
        [holo_pointers, zernike_scan_sequence] = f_sg_AO_make_zernike_pointers(app, AO_phase, reg1);
        
        num_scans = numel(holo_pointers);
        
        %%
        app.ZernikeReadyLamp.Color = [0.00,1.00,0.00];
    
        f_sg_EOF_Zscan(app, holo_pointers, num_scans, app.ScanZernikeButton, app.ScansperVolZEditField.Value);
        
        zernike_AO_data.zernike_scan_sequence = zernike_scan_sequence;
        zernike_AO_data.time_stamp = time_stamp;
        zernike_AO_data.zernike_table = app.ZernikeListTable.Data;
        zernike_AO_data.region_data = reg1;
        zernike_AO_data.correction_on = app.ApplyAOcorrectionButton.Value;
        
        save(sprintf('%s\\%s_iter%d_%d_%d_%dh_%dm.mat',...
            app.SLM_ops.save_AO_dir,...
            app.SavefiletagEditField.Value,...
            time_stamp(2), time_stamp(3), time_stamp(1)-2000, time_stamp(4),...
            time_stamp(5)), 'zernike_AO_data');
        
        app.ScanZernikeButton.Value = 0;
        app.ZernikeReadyLamp.Color = [0.80,0.80,0.80];
    catch
        disp('Zernike Scan failed');
        app.ScanZernikeButton.Value = 0;
        app.ZernikeReadyLamp.Color = [0.80,0.80,0.80];
        pause(0.05);
        f_SLM_update(app.SLM_ops, app.SLM_blank_pointer);
    end
    app.SLM_phase_corr_lut = init_phase_corr_lut;
    f_sg_upload_image_to_SLM(app);
else
    app.ZernikeReadyLamp.Color = [0.80,0.80,0.80];
end

end