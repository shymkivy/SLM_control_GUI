function f_sg_xyz_button_view_selected_phase(app)

if size(app.UIImagePhaseTableSelection,1) > 0
    coord = f_sg_mpl_get_coords(app, 'table_selection');
    
    holo_image = f_sg_xyz_gen_holo(app, coord, app.CurrentregionDropDown.Value);   
    
    f_sg_view_hologram_phase(app, holo_image);
    title(sprintf('Defocus %.1f um', app.UIImagePhaseTable.Data(app.UIImagePhaseTableSelection(1),3).Variables));
end

end