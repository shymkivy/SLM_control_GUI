function f_sg_scan_initialize_imaging(app)

if app.InitializeimagingButton.Value
    if or(~isempty(app.DAQ_session), app.ScanwithSLMtriggersCheckBox.Value)
        init_image_lut = app.SLM_phase_corr_lut;
        %try
        disp('Initializing multiplane imaging...');
        timestamp = f_sg_get_timestamp();
            
        if ~strcmpi(app.PatternDropDownCtr.Value, 'none')
            [holo_patterns_im, im_params, group_table_im] = f_sg_scan_make_images(app, app.PatternDropDownCtr.Value);
            num_planes = size(holo_patterns_im,3);
            volumes = app.NumVolumesEditField.Value;
            num_scans_all = num_planes*volumes;
        else
            num_planes = 0;
        end
        
        if ~strcmpi(app.PatternDropDownAI.Value, 'none')
            [holo_patterns_stim, stim_params, group_table_stim] = f_sg_scan_make_images(app, app.PatternDropDownAI.Value, 0);
            num_stim = size(holo_patterns_stim,3);
        else
            num_stim = 0;
        end
    
        if and(~num_stim, num_planes) % of only imaging
            disp('Running imaging only');
            
            holo_pointers = cell(num_planes,1);
            for n_gr = 1:num_planes
                holo_phase = init_image_lut;
                holo_phase(im_params.m_idx, im_params.n_idx) = holo_patterns_im(:,:, n_gr);
                holo_pointers{n_gr,1} = f_sg_initialize_pointer(app);
                holo_pointers{n_gr,1}.Value = reshape(holo_phase', [],1);
                %figure; imagesc(reshape(holo_pointers{n_gr,1}.Value, [1920 1152])')
            end
            app.ImagingReadyLamp.Color = [0.00,1.00,0.00];
    
            if app.ScanwithSLMtriggersCheckBox.Value
                %scan_data = f_sg_EOF_Zscan_trig(app, holo_pointers, num_scans_all, app.InitializeimagingButton);
                scan_data = f_sg_EOF_Zscan_trig_nodaq(app, holo_pointers, num_scans_all, app.InitializeimagingButton);
            else
                scan_data = f_sg_EOF_Zscan(app, holo_pointers, num_scans_all, app.InitializeimagingButton);
            end
            
            scan_data.group_table_im = group_table_im;
            scan_data.im_pattern = app.PatternDropDownCtr.Value;
            scan_data.volumes = volumes;
        elseif and(~num_planes, num_stim) % if only stim
            disp('Running stimulation only');
            
            holo_pointers = cell(1,num_stim+1);
            for n_st = 1:num_stim
                holo_phase = init_image_lut;
                holo_phase(stim_params.m_idx, stim_params.n_idx) = holo_patterns_stim(:,:, n_st);
                holo_pointers{1,n_st+1} = f_sg_initialize_pointer(app);
                holo_pointers{1,n_st+1}.Value = reshape(holo_phase', [],1);
                % figure; imagesc(reshape(holo_pointers{n_gr,n_st+1}.Value, [1920 1152])')
            end
            
            app.ImagingReadyLamp.Color = [0.00,1.00,0.00];
            if strcmpi(app.stimcontrolsourceButtonGroup.SelectedObject.Text, 'AI input')
                scan_data = f_sg_stim_scan(app, holo_pointers, app.InitializeimagingButton);
            elseif strcmpi(app.stimcontrolsourceButtonGroup.SelectedObject.Text, 'Custom stim')
                custom_stim = f_sg_gen_custom_stim_times(app, app.PatternDropDownAI.Value);
                scan_data = f_sg_stim_scan_custom(app, holo_pointers, custom_stim , app.InitializeimagingButton);
            end
            
            scan_data.stim_pattern = app.PatternDropDownAI.Value;
            scan_data.group_table_stim = group_table_stim;
        elseif and(num_planes, num_stim) % if both
            disp('Running both imaging and stimulation');
            
            holo_pointers = cell(num_planes,num_stim+1);
            for n_gr = 1:num_planes
                holo_phase = zeros(size(init_image_lut), 'uint8');
                holo_phase(im_params.m_idx, im_params.n_idx) = holo_patterns_im(:,:, n_gr);
                holo_pointers{n_gr,1} = f_sg_initialize_pointer(app);
                holo_pointers{n_gr,1}.Value = reshape(holo_phase', [],1);
                % figure; imagesc(reshape(holo_pointers{n_gr,1}.Value, [1920 1152])')
                for n_st = 1:num_stim
                    holo_phase(stim_params.m_idx, stim_params.n_idx) = holo_patterns_stim(:,:, n_st);
                    holo_pointers{n_gr,n_st+1} = f_sg_initialize_pointer(app);
                    holo_pointers{n_gr,n_st+1}.Value = reshape(holo_phase', [],1);
                    % figure; imagesc(reshape(holo_pointers{n_gr,n_st+1}.Value, [1920 1152])')
                end
            end
    
            app.ImagingReadyLamp.Color = [0.00,1.00,0.00];
            if strcmpi(app.stimcontrolsourceButtonGroup.SelectedObject.Text, 'AI input')
                scan_data = f_sg_EOF_Zscan_stim(app, holo_pointers, num_scans_all, app.InitializeimagingButton);
            elseif strcmpi(app.stimcontrolsourceButtonGroup.SelectedObject.Text, 'Custom stim')
                custom_stim = f_sg_gen_custom_stim_times(app, app.PatternDropDownAI.Value);
                scan_data = f_sg_EOF_Zscan_stim_custom(app, holo_pointers, custom_stim ,num_scans_all, app.InitializeimagingButton);
            end
            %f_sg_scan_EOF_trig(app, holo_pointers, num_scans_all, app.InitializeimagingButton);
            
            scan_data.group_table_im = group_table_im;
            scan_data.im_pattern = app.PatternDropDownCtr.Value;
            scan_data.volumes = volumes;
    
            scan_data.stim_pattern = app.PatternDropDownAI.Value;
            scan_data.group_table_stim = group_table_stim;
        else
            disp('No patterns to run are selected');
        end
        app.InitializeimagingButton.Value = 0;
        app.ImagingReadyLamp.Color = [0.80,0.80,0.80];
    
        if app.PlotSLMupdateratesCheckBox.Value
            if num_planes
                if numel(scan_data.frame_start_times)>3
                    figure;
                    plot(diff(scan_data.frame_start_times(2:end-1)));
                    xlabel('frame'); ylabel('time (ms)');
                    title('SLM update rate');
                end
            end
        end
        
        scan_data.xyz_patterns = app.xyz_patterns;
        scan_data.region_obj_params = app.region_obj_params;
        
        name_tag = sprintf('%s\\mpl_scan_%s', app.SLM_ops.save_dir, timestamp);
         
        save([name_tag '.mat'], 'scan_data');
        fprintf('Saved %s\n', name_tag);
    
        disp('Done');
            %figure; imagesc(f_sg_poiner_to_im(holo_pointers{1}, 1152, 1920));
    %     catch
    %         app.InitializeimagingButton.Value = 0;
    %         app.ImagingReadyLamp.Color = [0.80,0.80,0.80];
    %         disp('Imaging run failed')
    %     end
        app.SLM_phase_corr_lut = init_image_lut;
        f_sg_upload_image_to_SLM(app);
    else
        disp('Set up and initialize DAQ first')
        app.ImagingReadyLamp.Color = [0.80,0.80,0.80];
        app.InitializeimagingButton.Value = 0;
    end
else
    app.ImagingReadyLamp.Color = [0.80,0.80,0.80];
end


end