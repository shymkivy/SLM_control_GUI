function f_SLM_AO_plot_current_correction(app)

correction_im = app.current_SLM_AO_Image;
f_SLM_view_hologram_phase(app, correction_im);
title('Current AO wavefront');

end