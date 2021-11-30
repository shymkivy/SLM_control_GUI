function f_sg_view_current_lut(app)

text1 = {'on', 'off'};

holo_phase_lut = app.SLM_phase_corr_lut;
% corrections already added
figure;
app.hologram_fig_plot = newplot;
imagesc(app.hologram_fig_plot, holo_phase_lut);
axis(app.hologram_fig_plot, 'image');
caxis(app.hologram_fig_plot, [0 255]);
colorbar(app.hologram_fig_plot, 'eastoutside');
title(sprintf('Current uploaded phase after lut, AO %s', text1{2-app.ApplyAOcorrectionButton.Value}));

end