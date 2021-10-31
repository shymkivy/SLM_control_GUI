function regions_run = f_lut_get_regions_run2(slm_roi, num_regions_m, num_regions_n)

num_regions = num_regions_m * num_regions_n;

regions = (1:num_regions)-1;

regions_2d = reshape(regions, num_regions_n, num_regions_m)';

if numel(regions) > 1
    if strcmpi(slm_roi, 'full')
        regions_run = regions_2d;
    elseif strcmpi(slm_roi, 'left_half')
        regions_left = regions_2d(:,1:floor(num_regions_n/2));
        regions_run = regions_left;
    elseif strcmpi(slm_roi, 'right_half')
        regions_right = regions_2d(:,(floor(num_regions_n/2)+1:end));
        regions_run = regions_right;
    end
else
    regions_run = regions_2d;
end

end