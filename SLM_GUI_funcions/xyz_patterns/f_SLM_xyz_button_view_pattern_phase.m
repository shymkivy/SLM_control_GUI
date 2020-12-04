function f_SLM_xyz_button_view_pattern_phase(app)

coord = f_SLM_mpl_get_coords(app, 'pattern', round(app.PatternSpinner.Value));

holo_image = f_SLM_xyz_gen_holo(app, coord, app.GroupRegionDropDown.Value);  

f_SLM_view_hologram_phase(app, holo_image);

end