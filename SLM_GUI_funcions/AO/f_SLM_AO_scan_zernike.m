function f_SLM_AO_scan_zernike(app)

if app.ScanZernikeButton.Value
    try
        disp('Initializing Zernike Scan...')
        time_stamp = clock;
        
        %%
        %% create AO file
        AO_params = struct;
        AO_params.AO_iteration = 1;
        if app.ApplyAOcorrectionButton.Value
            reg1.AO_correction = app.AOcorrectionDropDown_2.Value;
            [AO_wf, AO_params] = f_SLM_AO_compute_wf(app, reg1);
        end
        
        [holo_pointers, zernike_scan_sequence] = f_SLM_AO_make_zernike_pointers(app, AO_wf);
        
        num_scans = numel(holo_pointers);
        
        %%
        init_image = app.SLM_Image;
        app.ZernikeReadyLamp.Color = [0.00,1.00,0.00];
    
        f_SLM_EOF_Zscan(app, holo_pointers, num_scans, app.ScanZernikeButton, app.ScansperVolZEditField.Value);
        
        app.SLM_Image = init_image;
        f_SLM_upload_image_to_SLM(app);
        
        if app.ApplyAOcorrectionButton.Value
            zernike_AO_data.current_correction_weights = app.AO_correction_data;
        else
            zernike_AO_data.current_correction_weights = 0;
        end
        zernike_AO_data.zernike_scan_sequence = zernike_scan_sequence;
        zernike_AO_data.time_stamp = time_stamp;
        zernike_AO_data.zernike_table = app.ZernikeListTable.Data;
        
        save(sprintf('%s\\%s_iter%d_%d_%d_%d_%dh_%dm.mat',...
            app.SLM_ops.save_AO_dir,...
            app.SavefiletagEditField.Value,  AO_params.AO_iteration,...
            time_stamp(2), time_stamp(3), time_stamp(1)-2000, time_stamp(4),...
            time_stamp(5)), 'zernike_AO_data', 'AO_params');
        
        app.ScanZernikeButton.Value = 0;
        app.ZernikeReadyLamp.Color = [0.80,0.80,0.80];
    catch
        disp('Zernike Scan failed');
        app.ScanZernikeButton.Value = 0;
        app.ZernikeReadyLamp.Color = [0.80,0.80,0.80];
        pause(0.05);
        f_SLM_BNS_update(app.SLM_ops, app.SLM_blank_pointer);
    end
else
    app.ZernikeReadyLamp.Color = [0.80,0.80,0.80];
end

end