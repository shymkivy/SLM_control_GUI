function f_sg_view_hologram_fft(app, im1_amp, axis1)

figure;
app.hologram_fig_plot = newplot;
imagesc(app.hologram_fig_plot,axis1, axis1, im1_amp);
axis(app.hologram_fig_plot, 'image');
%app.hologram_fig_plot.YDir = 'normal';
%caxis(app.hologram_fig_plot, [0 1]);
colorbar(app.hologram_fig_plot, 'eastoutside');
% if app.fftzoomed20xCheckBox.Value
%     xlim(app.hologram_fig_plot,[siz/2-siz/20 siz/2+siz/20]);
%     ylim(app.hologram_fig_plot,[siz/2-siz/20 siz/2+siz/20]);
% end

end