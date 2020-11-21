function f_SLM_LUT_run_calibration(app)

if app.RunLUTcalibrationButton.Value
    try
        disp('Initializing LUT calibration...')
        % generate coordinates
        SLMn = app.SLM_ops.width;
        SLMm = app.SLM_ops.height;
        beam_width = app.BeamdiameterpixEditField.Value;
        xlm = linspace(-SLMm/beam_width, SLMm/beam_width, SLMm);
        xln = linspace(-SLMn/beam_width, SLMn/beam_width, SLMn);
        [fX, fY] = meshgrid(xln, xlm);
        [theta, rho] = cart2pol( fX, fY );

        time_stamp = clock;
        
        %% generate pointers
        bit_depth = app.BitDepthEditField.Value;
        num_regions = app.NumRegionsEditField.Value;
        pixels_per_stripe = app.PixelsPerStripeEditField.Value;
        baseline_pixel_value = app.BaselinepixelvalueEditField.Value;
             
        if app.InsertrefimageinscansCheckBox.Value
            pix_range = repmat([999; (0:(bit_depth-1))'; 999],1,num_regions);
            region_range = [ones(1,2)*999; repmat(0:(num_regions-1),bit_depth,1); ones(1,2)*999];
        else
            pix_range = repmat((0:(bit_depth-1))',1,num_regions);
            region_range = repmat(0:(num_regions-1),bit_depth,1);
        end
        pix_region_table = cat(3,pix_range , region_range);
        pix_region_table = reshape(pix_region_table,[],2);
        
        num_pointers = size(pix_region_table,1);
        pointers_cell = cell(num_pointers,1);
        
        for n_point = 1:num_pointers
            gray_pix_val = pix_region_table(n_point,1);
            n_region = pix_region_table(n_point,2);
            if gray_pix_val == 999
                pointers_cell{n_point} = SLM_ref_im_pointer;
            else
                pointers_cell{n_point} = libpointer('uint8Ptr', zeros(SLMn*SLMm,1));
                calllib('ImageGen', 'Generate_Stripe', pointers_cell{n_point}, SLMn, SLMm, baseline_pixel_value, gray_pix_val, pixels_per_stripe);
                calllib('ImageGen', 'Mask_Image', pointers_cell{n_point}, SLMn, SLMm, n_region, num_regions);
            end
        end
        
        %%
        app.RunLUTcalibReadyLamp.Color = [0.00,1.00,0.00];

        f_SLM_EOF_scan(app, pointers_cell, num_pointers, app.RunLUTcalibrationButton);
        
        % store data from scan if succesfull
        app.AO_last_LUT_data{1} = pix_region_table;
        app.AO_last_LUT_data{2} = time_stamp;
        
        save(sprintf('%s\\LUT_calibration_GUI_data_%d_%d_%d_%dh_%dm.mat',...
            [app.SLM_ops.GUI_dir '\' app.LUTsavedirEditField.Value],...
            temp_time(2), temp_time(3), temp_time(1)-2000, temp_time(4),...
            temp_time(5)), 'pix_region_table', 'time_stamp');
        
        app.RunLUTcalibrationButton.Value = 0;
        app.RunLUTcalibReadyLamp.Color = [0.80,0.80,0.80];
        f_SLM_BNS_update(app.SLM_ops, app.SLM_blank_pointer);
    catch
        disp('LUT calibration failed');
        app.RunLUTcalibrationButton.Value = 0;
        app.RunLUTcalibReadyLamp.Color = [0.80,0.80,0.80];
        pause(0.05);
        f_SLM_BNS_update(app.SLM_ops, app.SLM_blank_pointer);
    end
else
    app.RunLUTcalibReadyLamp.Color = [0.80,0.80,0.80];
end

end