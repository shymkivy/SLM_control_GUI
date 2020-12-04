function f_SLM_xyz_button_upload_holo(app)

coord = f_SLM_mpl_get_coords(app, 'custom');

holo_image = f_SLM_xyz_gen_holo(app, coord, app.GroupRegionDropDown.Value);

app.SLM_Image = holo_image;   
f_SLM_upload_image_to_SLM(app);

end