function f_sg_view_hologram_fft(app, im1_amp, x_lab, y_lab)

figure;
app.hologram_fig_plot = newplot;
imagesc(app.hologram_fig_plot, y_lab, x_lab, im1_amp);
axis(app.hologram_fig_plot, 'image');
%app.hologram_fig_plot.YDir = 'normal';
%caxis(app.hologram_fig_plot, [0 1]);
colorbar(app.hologram_fig_plot, 'eastoutside');
% if app.fftzoomed20xCheckBox.Value
%     xlim(app.hologram_fig_plot,[siz/2-siz/20 siz/2+siz/20]);
%     ylim(app.hologram_fig_plot,[siz/2-siz/20 siz/2+siz/20]);
% end
axis equal tight

end