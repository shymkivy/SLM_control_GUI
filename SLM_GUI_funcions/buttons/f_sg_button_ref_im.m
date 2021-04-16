function f_sg_button_ref_im(app)

coords = f_sg_mpl_get_coords(app, 'zero');
coords.xyzp = [app.SLM_ops.ref_offset, 0, 0;...
               -app.SLM_ops.ref_offset, 0, 0;...
                0, app.SLM_ops.ref_offset, 0;...
                0,-app.SLM_ops.ref_offset, 0];
            
holo_image = f_sg_xyz_gen_holo(app, coords, app.CurrentregionDropDown.Value);
app.SLM_Image = holo_image;            
app.current_SLM_coord = coords;

app.SLM_Image_gh_preview = app.SLM_Image;
app.SLM_Image_plot.CData = app.SLM_Image;

f_sg_upload_image_to_SLM(app);    
fprintf('SLM ref image, %d  offset uploaded\n', app.SLM_ops.ref_offset);


end