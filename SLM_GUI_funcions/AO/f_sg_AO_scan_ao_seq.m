function num_scans_done = f_sg_AO_scan_ao_seq(app, holo_im_pointer, current_AO_phase, zernike_scan_sequence, ao_params)

reg1 = ao_params.region;

num_scans = numel(zernike_scan_sequence);
num_scans_done = 0;

for n_scan = 1:num_scans
    % add zernike pol on top of image
    full_corr = zernike_scan_sequence{n_scan};
    ao_corr = current_AO_phase + f_sg_AO_corr_to_phase(full_corr, ao_params);

%     n_mode = zernike_scan_sequence{n_scan}(1);
%     n_weight = zernike_scan_sequence{n_scan}(2);
%     ao_corr = current_AO_phase + ao_params.all_modes(:,:,n_mode)*n_weight;

    holo_phase_corr_lut = ao_params.init_phase_corr_lut;
    holo_phase_corr = angle(exp(1i*(ao_params.init_phase_corr_reg + ao_corr)));
    holo_phase_corr_lut(reg1.m_idx, reg1.n_idx) = f_sg_lut_apply_reg_corr(holo_phase_corr, reg1);
    holo_im_pointer.Value = reshape(holo_phase_corr_lut', [],1);

    f_SLM_update(app.SLM_ops, holo_im_pointer)
    pause(0.005); % wait 3ms for SLM to stabilize

    f_sg_scan_triggered_frame(app.DAQ_session, app.PostscandelayEditField.Value);
    
    num_scans_done = num_scans_done + 1;
end

end