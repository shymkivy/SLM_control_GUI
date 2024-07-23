function f_sg_lut_correctios_load_list(app)

corrections_dir = [app.SLM_ops.lut_dir '\' app.SLM_ops.SLM_params_use.lut_fname(1:end-4) '_correction'];

[lut_corr, ~] = f_sg_get_file_names(corrections_dir, '*.mat', 0);
lut_corr = [{'None'}; lut_corr];
app.lut_corrections_list = cell(numel(lut_corr),2);
app.lut_corrections_list(:,1) = lut_corr;

% load the mat files
if size(lut_corr,1) > 1
    for n_lut = 2:size(lut_corr,1)
        corr_data = load([corrections_dir '\' lut_corr{n_lut}]);
        app.lut_corrections_list{n_lut,2} = corr_data.lut_corr;
    end
end

end