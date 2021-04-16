function f_sg_xyz_button_upload_selected(app)

if size(app.UIImagePhaseTableSelection,1) > 0
    coord = f_sg_mpl_get_coords(app, 'table_selection');
   
    holo_image = f_sg_xyz_gen_holo(app, coord, app.CurrentregionDropDown.Value);
    app.SLM_Image =  holo_image;
    app.current_SLM_coord = coord;
    
    f_sg_upload_image_to_SLM(app);
end

end