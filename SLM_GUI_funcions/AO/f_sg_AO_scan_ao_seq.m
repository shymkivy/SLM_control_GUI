function [frames2, num_scans_done] = f_sg_AO_scan_ao_seq(app, input_AO_phase, zernike_scan_sequence, num_scans_done, ao_temp)

reg1 = ao_temp.reg1;
init_SLM_phase_corr_lut = ao_temp.init_SLM_phase_corr_lut;
holo_phase = ao_temp.current_holo_phase;

num_scans = numel(zernike_scan_sequence);

scan_start = num_scans_done + 1;
scan_end = (scan_start+num_scans-1);

for n_scan = 1:num_scans
    % add zernike pol on top of image
    full_corr = zernike_scan_sequence{n_scan};
    ao_corr = f_sg_AO_corr_to_phase(full_corr, ao_temp);

    % convert to exp and slm phase 
    complex_exp_corr = exp(1i*(holo_phase + input_AO_phase + ao_corr));
    SLM_phase_corr = angle(complex_exp_corr);
    
    % apply lut and upload
    init_SLM_phase_corr_lut(reg1.m_idx, reg1.n_idx) = f_sg_lut_apply_reg_corr(SLM_phase_corr, reg1);
    ao_temp.holo_im_pointer.Value = reshape(init_SLM_phase_corr_lut', [],1);

    f_SLM_update(app.SLM_ops, ao_temp.holo_im_pointer)
    pause(0.005); % wait 3ms for SLM to stabilize

    f_sg_scan_triggered_frame(app.DAQ_session, app.PostscandelayEditField.Value);
    
    num_scans_done = num_scans_done + 1;
end


num_scans_done = num_scans_done + num_scans;

% make extra scan because stupid scanimage
f_sg_scan_triggered_frame(app.DAQ_session, app.PostscandelayEditField.Value);
num_scans_done = num_scans_done + 1;
f_sg_AO_wait_for_frame_convert(path1, num_scans_done);

% load scanned frames
frames = f_sg_AO_get_all_frames(path1);
frames2 = frames(ao_temp.im_m_idx, ao_temp.im_n_idx, scan_start:scan_end);



end