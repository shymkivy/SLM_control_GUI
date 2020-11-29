function pt_ptr = f_SLM_xyz_create_pt(fov_fig, coord)

pt_ptr = images.roi.Point(fov_fig.Children, 'Color', 'r', 'Position', coord);
addlistener(pt_ptr,'ROIMoved',@f_SLM_xyz_allevents);
addlistener(pt_ptr,'DeletingROI',@f_SLM_xyz_allevents);

end