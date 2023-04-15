function num_scans_done = f_sg_AO_scan_z_defocus(app, holo_im_pointer, center_coord, z_range, current_AO, ao_params)

reg1 = ao_params.region;
init_SLM_phase_corr_lut = ao_params.init_SLM_phase_corr_lut;

num_scans_done = 0;
num_z = numel(z_range);

z_range2 = z_range + center_coord(3);

for n_z = 1:num_z
    temp_coord = center_coord;
    temp_coord.xyzp(3) = z_range2(n_z);
    temp_coord_corr = f_sg_coord_correct(reg1, temp_coord);
    
    temp_holo_phase = f_sg_PhaseHologram2(temp_coord_corr, reg1);
    
    % convert to exp and slm phase 
    complex_exp_corr = exp(1i*(temp_holo_phase+current_AO));
    SLM_phase_corr = angle(complex_exp_corr);

    % apply lut and upload
    init_SLM_phase_corr_lut(reg1.m_idx, reg1.n_idx) = f_sg_lut_apply_reg_corr(SLM_phase_corr, reg1);
    holo_im_pointer.Value = reshape(init_SLM_phase_corr_lut', [],1);
    
    f_SLM_update(app.SLM_ops, holo_im_pointer);
    pause(0.005); % wait 3ms for SLM to stabilize
    
    f_sg_scan_triggered_frame(app.DAQ_session, app.PostscandelayEditField.Value);
    
    num_scans_done = num_scans_done + 1;
end

end