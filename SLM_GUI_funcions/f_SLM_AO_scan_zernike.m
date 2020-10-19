function f_SLM_AO_scan_zernike(app)

if app.ScanZernikeButton.Value
    try
        disp('Initializing Zernike Scan...')
        % generate coordinates
        SLMn = app.SLM_ops.width;
        SLMm = app.SLM_ops.height;
        beam_width = app.BeamdiameterpixEditField.Value;
        xlm = linspace(-SLMm/beam_width, SLMm/beam_width, SLMm);
        xln = linspace(-SLMn/beam_width, SLMn/beam_width, SLMn);
        [fX, fY] = meshgrid(xln, xlm);
        [theta, rho] = cart2pol( fX, fY );
        
        time_stamp = clock;
        
        %% create pointers
        zernike_table = app.ZernikeListTable.Data;
        
        % generate all polynomials
        num_modes = size(zernike_table,1);
        all_modes = zeros(SLMm, SLMn, num_modes);
        for n_mode = 1:num_modes
            Z_nm = f_SLM_zernike_pol(rho, theta, zernike_table(n_mode,2), zernike_table(n_mode,3));
            all_modes(:,:,n_mode) = Z_nm;
        end
        
        % generate scan sequence
        all_patterns = cell(num_modes,1);
        for n_mode = 1:num_modes
            if zernike_table(n_mode,7)
                weights1 = zernike_table(n_mode,4):zernike_table(n_mode,5):zernike_table(n_mode,6);
                temp_patterns = [ones(numel(weights1),1)*zernike_table(n_mode,1), weights1']; 
                if app.InsertrefimageinscansCheckBox.Value
                    all_patterns{n_mode} = [999,999; temp_patterns];
                else
                    all_patterns{n_mode} = temp_patterns;
                end
            end
        end
        
        zernike_scan_sequence = cat(1,all_patterns{:});
        zernike_scan_sequence = repmat(zernike_scan_sequence,app.ScanspermodeEditField.Value,1);
        num_scans = size(zernike_scan_sequence,1);
        if app.ShufflemodesCheckBox.Value
            zernike_scan_sequence = zernike_scan_sequence(randsample(num_scans,num_scans),:);
        end

        % generate pointers
        holo_pointers = cell(num_scans,1);
        for n_plane = 1:num_scans
            n_mode = zernike_scan_sequence(n_plane,1);
            n_weight = zernike_scan_sequence(n_plane,2);
            if n_mode == 999
                holo_im = app.SLM_ref_im;
            else
                holo_im=angle(exp(1i*(all_modes(:,:,n_mode)*n_weight + app.SLM_Image)))+pi;
            end           
            holo_im = f_SLM_AO_add_correction(app,holo_im);
            %figure; imagesc(holo_im); title(['mode=' num2str(n_mode) ' weight=' num2str(n_weight)]);
            holo_pointers{n_plane} = f_SLM_convert_to_pointer(app, holo_im);
        end
        
        %%
        app.ZernikeReadyLamp.Color = [0.00,1.00,0.00];
    
        f_SLM_EOF_Zscan(app, holo_pointers, num_scans, app.ScanZernikeButton, app.ScansperVolZEditField.Value);
        
        if app.ApplyAOcorrectionButton.Value
            zernike_AO_data.current_correction_weights = app.AO_correction_data;
        else
            zernike_AO_data.current_correction_weights = 0;
        end
        zernike_AO_data.zernike_scan_sequence = zernike_scan_sequence;
        zernike_AO_data.time_stamp = time_stamp;
        zernike_AO_data.zernike_table = zernike_table;
        zernike_AO_data.coordinates = app.UITablecurrentcoord.Data;
        
        save(sprintf('%s\\%s\\%s_%d_%d_%d_%dh_%dm.mat',...
            app.SLM_ops.GUI_dir, app.AOsavedirEditField.Value,...
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