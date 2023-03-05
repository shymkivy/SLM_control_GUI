function f_sg_plot_phase_figure(phase, title_str)
figure; 
imagesc(phase);
axis tight equal;
caxis([0 2*pi]);
title(title_str);
end