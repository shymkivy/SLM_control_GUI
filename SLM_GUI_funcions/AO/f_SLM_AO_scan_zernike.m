function f_SLM_AO_scan_zernike(app)

if app.ScanZernikeButton.Value
    try
        disp('Initializing Zernike Scan...')
        time_stamp = clock;
        
        %%
        %% create AO file
        if app.ApplyAOcorrectionButton.Value
            AO_wf = f_SLM_AO_get_correction(app);
        end
        
        [holo_pointers, zernike_scan_sequence] = f_SLM_AO_make_zernike_pointers(app, AO_wf);
        
        num_scans = numel(holo_pointers);
        
        %%
        init_image = app.SLM_Image;
        app.ZernikeReadyLamp.Color = [0.00,1.00,0.00];
    
        f_sg_EOF_Zscan(app, holo_pointers, num_scans, app.ScanZernikeButton, app.ScansperVolZEditField.Value);
        
        app.SLM_Image = init_image;
        f_sg_upload_image_to_SLM(app);
        
        if app.ApplyAOcorrectionButton.Value
            zernike_AO_data.current_correction_weights = app.AO_correction_data;
        else
            zernike_AO_data.current_correction_weights = 0;
        end
        zernike_AO_data.zernike_scan_sequence = zernike_scan_sequence;
        zernike_AO_data.time_stamp = time_stamp;
        zernike_AO_data.zernike_table = app.ZernikeListTable.Data;
        
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
        f_SLM_BNS_update(app.SLM_ops, app.SLM_blank_pointer);
    end
else
    app.ZernikeReadyLamp.Color = [0.80,0.80,0.80];
end

end