function f_sg_scan_initialize_imaging(app)

if app.InitializeimagingButton.Value
    try
        disp('Initializing multiplane imaging...');
        time_stamp = clock;
        
        holo_patterns_im = f_sg_scan_make_images(app, app.PatternDropDownCtr.Value);
        
        num_planes = size(holo_patterns_im,3);
        volumes = app.NumVolumesEditField.Value;
        num_scans_all = num_planes*volumes;

        if ~strcmpi(app.PatternDropDownAI.Value, 'none')
            holo_patterns_stim = f_sg_scan_make_images(app, app.PatternDropDownAI.Value, 0);
            num_stim = size(holo_patterns_stim,3);
        else
            num_stim = 0;
        end
        
        im_pattern = app.xyz_patterns(strcmpi(app.PatternDropDownCtr.Value, [app.xyz_patterns.pat_name]));
        [m_idx_im, n_idx_im, ~,  reg1_im] = f_sg_get_reg_deets(app, im_pattern.SLM_region);
        
        lut_data = [];
        if ~isempty(reg1_im.lut_correction_data)
            lut_data2(1).lut_corr = reg1_im.lut_correction_data;
            lut_data2(1).m_idx = m_idx_im;
            lut_data2(1).n_idx = n_idx_im;
            lut_data = [lut_data; lut_data2];
        end
        
        if ~num_stim % of only imaging
            holo_pointers = cell(num_planes,1);
            for n_gr = 1:num_planes
                holo_phase = ones(app.SLM_ops.height, app.SLM_ops.width)+pi;
                holo_phase(m_idx_im, n_idx_im, n_gr) = holo_patterns_im(:,:, n_gr);
                holo_pointers{n_gr,1} = f_sg_initialize_pointer(app);
                holo_pointers{n_gr,1}.Value = f_sg_im_to_pointer_lut_corr(holo_phase(:,:,n_gr), lut_data);
                %figure; imagesc(holo_phase)
            end
            app.ImagingReadyLamp.Color = [0.00,1.00,0.00];
            scan_data = f_sg_EOF_Zscan(app, holo_pointers, num_scans_all, app.InitializeimagingButton);
            
        else
            stim_pattern = app.xyz_patterns(strcmpi(app.PatternDropDownAI.Value, [app.xyz_patterns.pat_name]));
            [m_idx_stim, n_idx_stim, ~,  reg1_stim] = f_sg_get_reg_deets(app, stim_pattern.SLM_region);
            
            if ~isempty(reg1_stim.lut_correction_data)
                lut_data2(1).lut_corr = reg1_stim.lut_correction_data;
                lut_data2(1).m_idx = m_idx_stim;
                lut_data2(1).n_idx = n_idx_stim;
                lut_data = [lut_data; lut_data2];
            end
            
            holo_pointers = cell(num_planes,num_stim+1);
            for n_gr = 1:num_planes
                holo_phase = ones(app.SLM_ops.height, app.SLM_ops.width)*pi;
                holo_phase(m_idx_im, n_idx_im) = holo_patterns_im(:,:, n_gr);
                holo_pointers{n_gr,1} = f_sg_initialize_pointer(app);
                holo_pointers{n_gr,1}.Value = f_sg_im_to_pointer_lut_corr(holo_phase, lut_data);
                %figure; imagesc(holo_phase)
                for n_st = 1:num_stim
                    holo_phase(m_idx_stim, n_idx_stim) = holo_patterns_stim(:,:, n_st);
                    holo_pointers{n_gr,n_st+1} = f_sg_initialize_pointer(app);
                    holo_pointers{n_gr,n_st+1}.Value = f_sg_im_to_pointer_lut_corr(holo_phase, lut_data);
                    %figure; imagesc(holo_phase)
                end
            end
            
            app.ImagingReadyLamp.Color = [0.00,1.00,0.00];
            scan_data = f_sg_EOF_Zscan_stim(app, holo_pointers, num_scans_all, app.InitializeimagingButton);
            %f_sg_scan_EOF_trig(app, holo_pointers, num_scans_all, app.InitializeimagingButton);
            
            scan_data.stim_pattern = stim_pattern;
        end
        app.InitializeimagingButton.Value = 0;
        app.ImagingReadyLamp.Color = [0.80,0.80,0.80];
        
        if app.PlotSLMupdateratesCheckBox.Value
            if numel(scan_data.frame_start_times)>3
                figure;
                plot(diff(scan_data.frame_start_times(2:end-1)));
                xlabel('frame'); ylabel('time (ms)');
                title('SLM update rate');
            end
        end
        scan_data.im_pattern = im_pattern;
        scan_data.volumes = volumes;
        
        name_tag = sprintf('%s\\%s_%d_%d_%d_%dh_%dm',...
            app.SLM_ops.save_dir,...
            'mpl_scan', ...
            time_stamp(2), time_stamp(3), time_stamp(1)-2000, time_stamp(4),...
            time_stamp(5));
        
        save([name_tag '.mat'], 'scan_data');
   
        disp('Done');
        
        %figure; imagesc(f_sg_poiner_to_im(holo_pointers{1}, 1152, 1920));
    catch
        app.InitializeimagingButton.Value = 0;
        app.ImagingReadyLamp.Color = [0.80,0.80,0.80];
        disp('Imaging run failed')
        f_SLM_update(app.SLM_ops, app.SLM_blank_pointer);
    end
else
    app.ImagingReadyLamp.Color = [0.80,0.80,0.80];
end


end