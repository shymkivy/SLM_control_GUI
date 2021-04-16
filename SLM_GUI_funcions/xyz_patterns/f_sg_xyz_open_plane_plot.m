function f_sg_xyz_open_plane_plot(app)

z_plane = app.planezSpinner.Value;

fov_fig = figure;
fov_im = imagesc(zeros(256,256));
axis equal tight;
hold on;
title(sprintf('z = %d', z_plane));
center = [256,256]/2;

coord = f_sg_mpl_get_coords(app, 'z_plane', z_plane);

if ~isempty(coord)
     for n_pt = 1:size(coord.xyzp,1)
         f_sg_xyz_create_pt(fov_fig.Children, center+[coord.xyzp(n_pt,1), coord.xyzp(n_pt,2)], coord.idx(n_pt),app);
     end
end

fov_im.ButtonDownFcn = @(~,~) f_sg_button_down(app, fov_fig);

end