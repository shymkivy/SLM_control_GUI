function f_SLM_xyz_open_pattern_plot(app)


n_pattern = app.PatternSpinner.Value;

fov_fig = figure;
fov_im = imagesc(zeros(256,256));
axis equal tight;
hold on;
title(sprintf('Pattern %d', n_pattern));

coord = f_SLM_mpl_get_coords(app, 'pattern', n_pattern)

fov_im.ButtonDownFcn = @(~,~) f_SLM_button_down(app, fov_fig);


end