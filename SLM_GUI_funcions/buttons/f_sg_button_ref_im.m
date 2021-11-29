function f_sg_button_ref_im(app)

coords = f_sg_mpl_get_coords(app, 'zero');
coords.xyzp = [app.SLM_ops.ref_offset, 0, 0;...
               -app.SLM_ops.ref_offset, 0, 0;...
                0, app.SLM_ops.ref_offset, 0;...
                0,-app.SLM_ops.ref_offset, 0];

[m_idx, n_idx, reg1] = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);
            
holo_complex = f_sg_xyz_gen_holo(app, coords, reg1);

app.SLM_phase_corr(m_idx, n_idx) = angle(holo_complex);            
app.current_SLM_coord = coords;

app.SLM_gh_phase_preview = app.SLM_phase_corr;
app.SLM_phase_plot.CData = app.SLM_phase_corr+pi;

f_sg_upload_image_to_SLM(app);    
fprintf('SLM ref image, %d  offset uploaded\n', app.SLM_ops.ref_offset);


end