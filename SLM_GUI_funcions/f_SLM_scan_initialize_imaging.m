function f_SLM_scan_initialize_imaging(app)

if app.InitializeimagingButton.Value
    try
        disp('Initializing multiplane imaging...');
        
        [holo_patterns_ctr, reg_idx_ctr] = f_SLM_scan_make_pointer_images(app, app.PatternDropDownCtr.Value);
        [holo_patterns_ai, reg_idx_ai] = f_SLM_scan_make_pointer_images(app, app.PatternDropDownAI.Value, 1);
        
        num_groups = size(holo_patterns_ctr,2);
        volumes = app.NumVolumesEditField.Value;
        num_planes_all = num_groups*volumes;
        
        if app.AllButton.Value
            num_stim = size(holo_patterns_ai,2);
            holo_pointers = cell(num_groups,num_stim);
            for n_gr = 1:num_groups
                for n_st = 1:num_stim
                    holo_pointers{n_gr,n_st} = f_SLM_initialize_pointer(app);
                    holo_pointers{n_gr,n_st}.Value(reg_idx_ctr) = holo_patterns_ctr(:,n_gr);
                    holo_pointers{n_gr,n_st}.Value(reg_idx_ai) = holo_patterns_ai(:,n_st);
                end
            end
            
            %figure; imagesc(reshape(holo_pointers{1,2}.Value,1920,[]));
            
            app.ImagingReadyLamp.Color = [0.00,1.00,0.00];

            f_SLM_scan_EOF_trig(app, holo_pointers, num_planes_all, app.InitializeimagingButton);

            app.InitializeimagingButton.Value = 0;
            app.ImagingReadyLamp.Color = [0.80,0.80,0.80];
        elseif app.EOFonlyButton.Value
            holo_pointers = cell(num_groups,1);
            for n_gr = 1:num_groups
                holo_pointers{n_gr} = f_SLM_initialize_pointer(app);
                holo_pointers{n_gr}.Value(reg_idx_ctr) = holo_patterns_ctr(:,n_gr);                
            end

            app.ImagingReadyLamp.Color = [0.00,1.00,0.00];

            f_SLM_scan_EOF_trig2(app, holo_pointers, holo_patterns_ai, reg_idx_ai, num_planes_all, app.InitializeimagingButton);

            app.InitializeimagingButton.Value = 0;
            app.ImagingReadyLamp.Color = [0.80,0.80,0.80];
        end
        
    catch
        app.InitializeimagingButton.Value = 0;
        app.ImagingReadyLamp.Color = [0.80,0.80,0.80];
        disp('Imaging run failed')
        f_SLM_BNS_update(app.SLM_ops, app.SLM_blank_pointer);
    end
else
    app.ImagingReadyLamp.Color = [0.80,0.80,0.80];
end


end