function regions_run = f_lut_get_regions_run(slm_roi, NumRegions)

regions = (1:NumRegions)-1;

if numel(regions) > 1
    if strcmpi(slm_roi, 'full')
        regions_run = regions;
    elseif strcmpi(slm_roi, 'left_half')
        [rows, cols] = ind2sub([sqrt(numel(regions)) sqrt(numel(regions))], 1:numel(regions));
        ind1 = sub2ind([sqrt(numel(regions)) sqrt(numel(regions))], cols(cols<=(max(cols)/2)), rows(cols<=(max(cols)/2)));
        regions_run = sort(regions(ind1));
    elseif strcmpi(slm_roi, 'right_half')
        [rows, cols] = ind2sub([sqrt(numel(regions)) sqrt(numel(regions))], 1:numel(regions));
        ind1 = sub2ind([sqrt(numel(regions)) sqrt(numel(regions))], cols(cols>(max(cols)/2)), rows(cols<=(max(cols)/2)));
        regions_run = sort(regions(ind1));
    end
else
    regions_run = regions;
end

end