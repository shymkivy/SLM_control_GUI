function f_sg_view_hologram_phase(app, holo_phase)

figure;
app.hologram_fig_plot = newplot;
imagesc(app.hologram_fig_plot, holo_phase + pi);
axis(app.hologram_fig_plot, 'image');
%caxis(app.hologram_fig_plot, [0 2*pi]);
colorbar(app.hologram_fig_plot, 'eastoutside');

end