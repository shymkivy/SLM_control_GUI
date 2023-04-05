function num_scans_done = f_sg_AO_scan_ao_seq(current_AO_phase, mode_seq, weight_seq, all_modes)

num_scans = numel(mode_seq);

num_scans_done = 0;

for n_scan = 1:num_scans
    % add zernike pol on top of image
    n_mode = mode_seq(n_scan);
    n_weight = weight_seq(n_scan);
    ao_corr = current_AO_phase + all_modes(:,:,n_mode)*n_weight;

    holo_phase_corr_lut = init_phase_corr_lut;
    holo_phase_corr = angle(exp(1i*(init_phase_corr + ao_corr)));
    holo_phase_corr_lut(reg1.m_idx, reg1.n_idx) = f_sg_lut_apply_reg_corr(holo_phase_corr, reg1);
    holo_im_pointer.Value = reshape(holo_phase_corr_lut', [],1);

    f_SLM_update(app.SLM_ops, holo_im_pointer)
    pause(0.005); % wait 3ms for SLM to stabilize

    f_sg_scan_triggered_frame(app.DAQ_session, app.PostscandelayEditField.Value);
    
    num_scans_done = num_scans_done + 1;

end


end