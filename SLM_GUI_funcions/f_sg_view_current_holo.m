function f_sg_view_current_holo(app)

holo_image = app.SLM_image;
holo_image = f_sg_AO_add_correction(holo_image, app.current_SLM_AO_Image);
f_sg_view_hologram_phase(app, holo_image);
title('Current uploaded phase');

end