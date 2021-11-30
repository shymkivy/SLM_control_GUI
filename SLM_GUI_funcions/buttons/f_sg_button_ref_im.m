function f_sg_button_ref_im(app)

coords = f_sg_mpl_get_coords(app, 'zero');
coords.xyzp = [app.SLM_ops.ref_offset, 0, 0;...
               -app.SLM_ops.ref_offset, 0, 0;...
                0, app.SLM_ops.ref_offset, 0;...
                0,-app.SLM_ops.ref_offset, 0];

[m_idx, n_idx, reg1] = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);
            
holo_phase = f_sg_xyz_gen_holo(app, coords, reg1);

SLM_phase = angle(sum(exp(1i*(holo_phase)),3));

app.SLM_phase_corr(m_idx, n_idx) = SLM_phase;            
app.current_SLM_coord = coords;

app.SLM_gh_phase_preview = app.SLM_phase_corr;
app.SLM_phase_plot.CData = app.SLM_phase_corr+pi;

%% apply lut correction
app.SLM_phase_lut_corr(m_idx, n_idx) = f_sg_lut_apply_reg_corr(app.SLM_phase_corr, reg1);

%% upload
f_sg_upload_image_to_SLM(app);    
fprintf('SLM ref image, %d  xy offsets uploaded\n', app.SLM_ops.ref_offset);


end