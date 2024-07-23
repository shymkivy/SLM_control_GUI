function f_sg_LUT_run_calibration(app)

if app.RunLUTcalibrationButton.Value
    try
        disp('Initializing LUT calibration...')
        % generate coordinates
        SLMn = app.SLM_ops.sdkObj.width;
        SLMm = app.SLM_ops.sdkObj.height;
        reg1 = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);

        xlm = linspace(-SLMm/reg1.phase_diameter, SLMm/reg1.phase_diameter, SLMm);
        xln = linspace(-SLMn/reg1.phase_diameter, SLMn/reg1.phase_diameter, SLMn);
        [fX, fY] = meshgrid(xln, xlm);
        [theta, rho] = cart2pol( fX, fY );

        timestamp = f_sg_get_timestamp();
        
        %% generate pointers
        bit_depth = app.BitDepthEditField.Value;
        num_regions = app.NumRegionsEditField.Value;
        pixels_per_stripe = app.PixelsPerStripeEditField.Value;
        baseline_pixel_value = app.BaselinepixelvalueEditField.Value;
             
        pix_range = repmat((0:(bit_depth-1))',1,num_regions);
        region_range = repmat(0:(num_regions-1),bit_depth,1);
        
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

        f_sg_EOF_scan(app, pointers_cell, num_pointers, app.RunLUTcalibrationButton);
        
        % store data from scan if succesfull
        app.AO_last_LUT_data{1} = pix_region_table;
        app.AO_last_LUT_data{2} = timestamp;
        
        save(sprintf('%s\\LUT_calibration_GUI_data_%s.mat',...
            [app.SLM_ops.GUI_dir '\' app.LUTsavedirEditField.Value],...
            timestamp), 'pix_region_table', 'time_stamp');
        
        app.RunLUTcalibrationButton.Value = 0;
        app.RunLUTcalibReadyLamp.Color = [0.80,0.80,0.80];
        f_SLM_update(app.SLM_ops, app.SLM_blank_pointer);
    catch
        disp('LUT calibration failed');
        app.RunLUTcalibrationButton.Value = 0;
        app.RunLUTcalibReadyLamp.Color = [0.80,0.80,0.80];
        pause(0.05);
        f_SLM_update(app.SLM_ops, app.SLM_blank_pointer);
    end
else
    app.RunLUTcalibReadyLamp.Color = [0.80,0.80,0.80];
end

end