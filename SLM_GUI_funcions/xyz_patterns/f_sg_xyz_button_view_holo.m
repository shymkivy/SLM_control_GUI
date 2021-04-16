function f_sg_xyz_button_view_holo(app)

coord = f_sg_mpl_get_coords(app, 'custom');

holo_image = f_sg_xyz_gen_holo(app, coord, app.CurrentregionDropDown.Value);

f_sg_view_hologram_phase(app, holo_image);
title(sprintf('Defocus %.1f um', app.ZOffsetumEditField.Value));

end