function f_SLM_xyz_button_view_holo(app)

coord = f_SLM_mpl_get_coords(app, 'custom');

holo_image = f_SLM_xyz_gen_holo(app, coord, app.CurrentregionDropDown.Value);

f_SLM_view_hologram_phase(app, holo_image);
title(sprintf('Defocus %.1f um', app.ZOffsetumEditField.Value));

end