function pt_ptr = f_sg_xyz_create_pt(ax1, coord, idx, app)

pt_ptr = images.roi.Point(ax1, 'Color', 'r', 'Position', coord);
pt_ptr.Label = num2str(idx);
addlistener(pt_ptr,'ROIMoved',@(h,evt)f_sg_xyz_allevents(h,evt,app));
addlistener(pt_ptr,'DeletingROI',@(h,evt)f_sg_xyz_allevents(h,evt,app));

end