function f_SLM_AO_generate_AO_image(app)

try    
    app.SLM_ops.zernike_file_names = f_SLM_get_file_names([app.SLM_ops.GUI_dir '\' app.SLM_ops.xyz_calibration_dir], '*ernike*.mat', false);
    app.AOcorrectionfilesDropDown.Items  = app.SLM_ops.zernike_file_names;
    app.AO_correction_data = load([app.SLM_ops.GUI_dir '\' app.CalibrationdirEditField.Value '\' app.AOcorrectionfilesDropDown.Value]);
    zernike_computed_weights = app.AO_correction_data.zernike_computed_weights;
    
    SLMn = app.SLM_ops.width;
    SLMm = app.SLM_ops.height;
    beam_width = app.BeamdiameterpixEditField.Value;
    xlm = linspace(-SLMm/beam_width, SLMm/beam_width, SLMm);
    xln = linspace(-SLMn/beam_width, SLMn/beam_width, SLMn);
    [fX, fY] = meshgrid(xln, xlm);
    [theta, rho] = cart2pol( fX, fY );
    
    num_modes = numel(zernike_computed_weights);
    all_modes = zeros(SLMm, SLMn, num_modes);
    % generate all polynomials
    for n_mode = 1:num_modes
        Z_nm = f_SLM_zernike_pol(rho, theta, zernike_computed_weights(n_mode).Zn, zernike_computed_weights(n_mode).Zm);
        all_modes(:,:,n_mode) = Z_nm;
    end

    SLM_AO_Image = zeros(SLMm,SLMn);
    for n_pol = 1:num_modes
        SLM_AO_Image = SLM_AO_Image+all_modes(:,:,n_pol)*zernike_computed_weights(n_pol).max_hwm_ratio_ind;
    end    
    %figure; imagesc(SLM_AO_Image); axis equal tight;    
    app.SLM_AO_Image=angle(exp(1i*SLM_AO_Image))+pi;    
    %figure; imagesc(app.SLM_AO_Image); axis equal tight;
    app.AO_correction_ready = 1;
    app.AOcorrectionavailableLamp.Color = [0, 1, 0];
catch
    app.AO_correction_ready = 0;
    app.AOcorrectionavailableLamp.Color = [0.80,0.80,0.80];
end

end