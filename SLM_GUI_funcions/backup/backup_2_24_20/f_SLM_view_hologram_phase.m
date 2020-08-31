function f_SLM_view_hologram_phase(app, holo_image)
    figure;
    app.hologram_fig_plot = newplot;
    imagesc(app.hologram_fig_plot, holo_image);
    axis(app.hologram_fig_plot, 'image');
    caxis(app.hologram_fig_plot, [0 2*pi]);
    colorbar(app.hologram_fig_plot, 'eastoutside');
end