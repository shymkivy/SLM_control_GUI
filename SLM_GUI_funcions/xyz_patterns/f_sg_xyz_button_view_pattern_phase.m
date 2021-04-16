function f_sg_xyz_button_view_pattern_phase(app)

coord = f_sg_mpl_get_coords(app, 'pattern', round(app.PatternSpinner.Value));

holo_image = f_sg_xyz_gen_holo(app, coord, app.CurrentregionDropDown.Value);  

f_sg_view_hologram_phase(app, holo_image);

end