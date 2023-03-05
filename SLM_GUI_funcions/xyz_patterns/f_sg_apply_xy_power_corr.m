function power_out = f_sg_apply_xy_power_corr(corr_data, xy_coords)

num_pts = size(xy_coords,1);
power_out = ones(num_pts,1);

if ~isempty(corr_data)
    [~, x_idx] = min((xy_coords(:,1) - corr_data.x_coord).^2,[],2);
    [~, y_idx] = min((xy_coords(:,2) - corr_data.y_coord).^2,[],2);
    for n_pt = 1:num_pts
        power_out(n_pt) = corr_data.pw_map_2d(y_idx(n_pt), x_idx(n_pt));
    end
end

end