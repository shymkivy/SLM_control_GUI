function lut_correction = f_sg_get_corr_data(app, lut_corr_fname)

% get reg
if ~isempty(lut_corr_fname)
    lut_corr_idx = strcmpi(app.lut_corrections_list(:,1), lut_corr_fname);
    lut_correction = app.lut_corrections_list{lut_corr_idx,2}.lut_corr;
else
    lut_correction = [];
end

end