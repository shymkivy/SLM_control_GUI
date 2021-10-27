function lut_correction_data = f_sg_get_corr_data(app)

% get reg
[~, ~,~, reg1] = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);

idx_reg = strcmpi(reg1.name_tag, [app.region_list.name_tag]);
if ~isempty(app.region_list(idx_reg).lut_correction)
    idx_lut_corr = strcmpi(app.region_list(idx_reg).lut_correction(:,1), app.SLM_ops.lut_fname);
    lut_corr_idx = strcmpi(app.lut_corrections_list(:,1), app.region_list(idx_reg).lut_correction{idx_lut_corr,2});
    lut_correction_data = app.lut_corrections_list{lut_corr_idx,2}.lut_corr;
else
    lut_correction_data = [];
end

% if ~isempty(lut_correction_data)
%     %im_out = f_sg_poiner_to_im(pointer_in, app.SLM_oSLMm, SLMn)
%     
%     
%     pointer_out.Value = round(lut_correction_data(pointer.Value+1,2));
% else
%     pointer_out = pointer;
% end

end