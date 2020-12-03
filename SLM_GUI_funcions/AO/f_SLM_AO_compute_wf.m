function [wf_out, used_modes, used_weights] = f_SLM_AO_compute_wf(app, reg1, num_modes)

if strcmpi(reg1.AO_correction, 'none')
    wf_out = [];
else
    if num_modes
        idx_AO = strcmpi(reg1.AO_correction, app.SLM_ops.AO_correction(:,1));
        zer_data = app.SLM_ops.AO_correction{idx_AO,2}.zernike_computed_weights;
        intens_change_vals = [zer_data.intensity_change];
        [~, idx_sort] = sort(intens_change_vals, 'descend');
        
        [m_idx, n_idx] = f_SLM_get_reg_deets(app, reg1.name_tag);
        
        SLMm = sum(m_idx);
        SLMn = sum(n_idx);
        
        beam_width = max([SLMm SLMn]);
        
        xlm = linspace(-SLMm/beam_width, SLMm/beam_width, SLMm);
        xln = linspace(-SLMn/beam_width, SLMn/beam_width, SLMn);
        
        [fX, fY] = meshgrid(xln, xlm);
        [theta, rho] = cart2pol( fX, fY );
        
        
        % generate all polynomials
        all_modes = zeros(SLMm, SLMn, num_modes);
        for n_mode_idx = 1:num_modes
            n_mode = idx_sort(n_mode_idx);
            Z_nm = f_SLM_zernike_pol(rho, theta, zer_data(n_mode).Zn, zer_data(n_mode).Zm);
            all_modes(:,:,n_mode_idx) = Z_nm*zer_data(n_mode).best_intensity_weight;
        end
        
        used_modes = [zer_data(idx_sort(1:num_modes)).mode];
        used_weights = [zer_data(idx_sort(1:num_modes)).best_intensity_weight];
        
        wf_out = sum(all_modes,3);
        %figure; imagesc(wf_out)
    else
        wf_out = [];
    end
end

end