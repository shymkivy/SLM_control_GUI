function f_SLM_x_offset(app)

app.SLM_Image = app.SLM_X_offset_im;
app.current_SLM_coord = f_SLM_mpl_get_coords(app, 'zero');
app.current_SLM_coord.xyzp = [app.SLM_ops.X_offset, 0, 0];
app.UITablecurrentcoord.Data = app.current_SLM_coord.xyzp;
f_SLM_upload_image_to_SLM(app);    
disp('SLM X offset uploaded');

end