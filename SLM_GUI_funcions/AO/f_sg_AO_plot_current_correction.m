function f_sg_AO_plot_current_correction(app)

f_sg_view_hologram_phase(app, exp(1i*app.current_SLM_AO_Image));
title('Current AO wavefront');

end