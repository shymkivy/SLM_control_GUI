function f_SLM_xyz_button_upload_pattern(app)

coord = f_SLM_mpl_get_coords(app, 'pattern', round(app.PatternSpinner.Value));

app.current_SLM_coord = coord;
app.UITablecurrentcoord.Data = app.current_SLM_coord.xyzp;

% get region
[m_idx, n_idx, xyz_affine_tf_mat] = f_SLM_get_reg_deets(app, app.GroupRegionDropDown.Value);
SLMm = sum(m_idx);
SLMn = sum(n_idx);

coord.xyzp = (xyz_affine_tf_mat*coord.xyzp')';

% make im;
holo_image = app.SLM_Image;
holo_image(m_idx,n_idx) =  f_SLM_gen_holo_multiplane_image(app, coord, SLMm, SLMn);

app.SLM_Image = holo_image;    
f_SLM_upload_image_to_SLM(app);
end