function f_SLM_button_xy_offset(app)

coords = f_SLM_mpl_get_coords(app, 'zero');
coords.xyzp = [app.SLM_ops.X_offset, app.SLM_ops.Y_offset, 0];
app.current_SLM_region = app.CurrentregionDropDown.Value;

holo_image = f_SLM_xyz_gen_holo(app, coords, app.CurrentregionDropDown.Value);
app.SLM_Image = holo_image;

f_SLM_upload_image_to_SLM(app);    
fprintf('SLM XY offset (%d,%d) uploaded \n', app.SLM_ops.X_offset, app.SLM_ops.Y_offset);

app.current_SLM_coord = coords;

end