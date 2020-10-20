function f_SLM_xyz_button_upload_holo(app)


coord = f_SLM_mpl_get_coords(app, 'custom');
app.current_SLM_coord = coord;
app.UITablecurrentcoord.Data = app.current_SLM_coord.xyzp;

% get roi
[m, n] = f_SLM_xyz_get_roimn(app);
SLMm = m(2) - m(1) + 1;
SLMn = n(2) - n(1) + 1;

% make im;
holo_image = app.SLM_blank_im;
holo_image(m(1):m(2),n(1):n(2)) =  f_SLM_gen_holo_multiplane_image(app, coord, SLMm, SLMn);
    
app.SLM_Image =  holo_image;   
f_SLM_upload_image_to_SLM(app);

end