function [tab_data, powers_all] = f_sg_update_table_power_core(corr_data, tab_data)

num_pts = numel(tab_data.X);
powers_all = ones(num_pts,1);

if ~isempty(corr_data)
    [~, x_idx] = min((tab_data.X - corr_data.x_coord).^2,[],2);
    [~, y_idx] = min((tab_data.Y - corr_data.y_coord).^2,[],2);
    for n_pt = 1:num_pts
        powers_all(n_pt) = corr_data.pw_map_2d(y_idx(n_pt), x_idx(n_pt));
    end
end

weights_all = tab_data.Weight/sum(tab_data.Weight);
powers_corr = powers_all.*weights_all;

tab_data.Power = powers_corr;

end