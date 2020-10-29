function f_SLM_ref_im_button(app)

app.SLM_Image = app.SLM_ref_im;
app.current_SLM_coord = f_SLM_mpl_get_coords(app, 'zero');
app.current_SLM_coordxyzp = [app.SLM_ops.ref_offset, 0, 0;...
                               -app.SLM_ops.ref_offset, 0, 0;...
                                0, app.SLM_ops.ref_offset, 0;...
                                0,-app.SLM_ops.ref_offset, 0];
app.UITablecurrentcoord.Data = app.current_SLM_coord.xyzp;
f_SLM_upload_image_to_SLM(app);    
disp('SLM ref image uploaded');


end