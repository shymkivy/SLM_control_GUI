function [frames_out, num_scans_done] = f_sg_AO_scan_z_defocus(app, z_range, num_scans_done, ao_temp)

reg1 = ao_temp.reg1;
init_SLM_phase_corr_lut = ao_temp.init_SLM_phase_corr_lut;
center_coord = ao_temp.current_coord;
current_AO_phase = ao_temp.current_AO_phase;

num_scans = numel(z_range);

z_range2 = z_range + center_coord.xyzp(3);

scan_start = num_scans_done + 1;
scan_end = (scan_start+num_scans-1);

for n_z = 1:num_scans
    temp_coord = center_coord;
    temp_coord.xyzp(3) = z_range2(n_z);
    temp_coord_corr = f_sg_coord_correct(reg1, temp_coord);
    
    temp_holo_phase = f_sg_PhaseHologram2(temp_coord_corr, reg1);
    
    % convert to exp and slm phase 
    complex_exp_corr = exp(1i*(temp_holo_phase+current_AO_phase));
    SLM_phase_corr = angle(complex_exp_corr);

    if reg1.zero_outside_phase_diameter
        SLM_phase_corr(~reg1.holo_mask) = 0;
    end

    % apply lut and upload
    init_SLM_phase_corr_lut(reg1.m_idx, reg1.n_idx) = f_sg_lut_apply_reg_corr(SLM_phase_corr, reg1);
    ao_temp.holo_im_pointer.Value = reshape(init_SLM_phase_corr_lut', [],1);
    
    f_SLM_update(app.SLM_ops, ao_temp.holo_im_pointer);
    pause(0.005); % wait 3ms for SLM to stabilize
    
    f_sg_scan_triggered_frame(app.DAQ_session, app.PostscandelayEditField.Value);
end
num_scans_done = num_scans_done + num_scans;

% make extra scan because stupid scanimage
f_sg_scan_triggered_frame(app.DAQ_session, app.PostscandelayEditField.Value);
num_scans_done = num_scans_done + 1;
f_sg_AO_wait_for_frame_convert(ao_temp.scan_path, num_scans_done);

% load scanned frames
frames = f_sg_AO_get_all_frames(ao_temp.scan_path);
frames_out = frames(ao_temp.im_m_idx, ao_temp.im_n_idx, scan_start:scan_end);

end