function f_SLM_scan_initialize_imaging(app)

if app.InitializeimagingButton.Value
    try
        disp('Initializing multiplane imaging...');
        time_stamp = clock;
        
        [holo_patterns_ctr, out_params_imaging] = f_SLM_scan_make_images(app, app.PatternDropDownCtr.Value);
        
        num_planes = size(holo_patterns_ctr,3);
        volumes = app.NumVolumesEditField.Value;
        num_scans_all = num_planes*volumes;
        
        % make imaging core holograms
        holo_phase_core = zeros(app.SLM_ops.height, app.SLM_ops.width, num_planes)+pi;
        for n_pl = 1:num_planes
            holo_phase_core(out_params_imaging.m_idx, out_params_imaging.n_idx, n_pl) = holo_patterns_ctr(:,:, n_pl);
        end
        
        if ~strcmpi(app.PatternDropDownAI.Value, 'none')
            [holo_patterns_ai, out_params_stim] = f_SLM_scan_make_images(app, app.PatternDropDownAI.Value, 0);
            num_stim = size(holo_patterns_ai,2);
        else
            num_stim = 0;
        end
        
        if ~num_stim % of only imaging
            holo_pointers = cell(num_planes,1);
            for n_gr = 1:num_planes
                holo_pointers{n_gr,1} = f_SLM_initialize_pointer(app);
                holo_pointers{n_gr,1}.Value = f_SLM_im_to_pointer(holo_phase_core(:,:,n_gr));
            end
            app.ImagingReadyLamp.Color = [0.00,1.00,0.00];
            scan_data = f_SLM_EOF_Zscan(app, holo_pointers, num_scans_all, app.InitializeimagingButton);
            
        elseif app.AllButton.Value
            holo_pointers = cell(num_planes,num_stim+1);
            for n_gr = 1:num_planes
                for n_st = 1:(num_stim+1)
                    holo_pointers{n_gr,n_st} = f_SLM_initialize_pointer(app);
                    holo_pointers{n_gr,n_st}.Value(reg_idx_ctr) = holo_patterns_ctr(:,n_gr);
                    holo_pointers{n_gr,n_st}.Value(~reg_idx_ctr) = holo_patterns_ai(:,n_st);
                end
            end
            
            app.ImagingReadyLamp.Color = [0.00,1.00,0.00];
            scan_data = f_SLM_EOF_Zscan(app, holo_pointers, num_scans_all, app.InitializeimagingButton);
            %f_SLM_scan_EOF_trig(app, holo_pointers, num_planes_all, app.InitializeimagingButton);
            
        elseif app.EOFonlyButton.Value
            holo_pointers = cell(num_planes,1);
            for n_gr = 1:num_planes
                holo_pointers{n_gr} = f_SLM_initialize_pointer(app);
                holo_pointers{n_gr}.Value(reg_idx_ctr) = holo_patterns_ctr(:,n_gr);                
            end
            app.ImagingReadyLamp.Color = [0.00,1.00,0.00];
            scan_data = f_SLM_scan_EOF_trig2(app, holo_pointers, holo_patterns_ai, reg_idx_ai, num_scans_all, app.InitializeimagingButton);
            
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
        scan_data.im_pattern = app.xyz_patterns(strcmpi([app.xyz_patterns.name_tag], {app.PatternDropDownCtr.Value}));
        scan_data.volumes = volumes;
        
        name_tag = sprintf('%s\\%s_%d_%d_%d_%dh_%dm',...
            app.SLM_ops.save_dir,...
            'mpl_scan', ...
            time_stamp(2), time_stamp(3), time_stamp(1)-2000, time_stamp(4),...
            time_stamp(5));
        
        save([name_tag '.mat'], 'scan_data');
   
        disp('Done');
        
        %figure; imagesc(f_SLM_poiner_to_im(holo_pointers{1}, 1152, 1920));
    catch
        app.InitializeimagingButton.Value = 0;
        app.ImagingReadyLamp.Color = [0.80,0.80,0.80];
        disp('Imaging run fangiled')
        f_SLM_BNS_update(app.SLM_ops, app.SLM_blank_pointer);
    end
else
    app.ImagingReadyLamp.Color = [0.80,0.80,0.80];
end


end