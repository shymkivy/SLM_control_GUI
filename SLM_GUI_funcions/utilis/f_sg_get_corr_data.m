function lut_correction = f_sg_get_corr_data(app, lut_corr_fname)

% get reg
lut_correction = [];
if ~isempty(lut_corr_fname)
    lut_corr_idx = strcmpi(app.lut_corrections_list(:,1), lut_corr_fname);
    if sum(lut_corr_idx)
    	lut_correction = app.lut_corrections_list{lut_corr_idx,2}.lut_corr;
    end
end

end