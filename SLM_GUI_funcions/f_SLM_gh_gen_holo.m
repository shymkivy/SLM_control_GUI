function f_SLM_gh_gen_holo(app, pattern)

% get roi
[m_idx, n_idx] = f_SLM_gh_get_roimn(app);
SLMm = sum(m_idx);
SLMn = sum(n_idx);

pointer = f_SLM_gh_gen_image(app, pattern, SLMm, SLMn);

% lut correction
idx_roi = strcmpi(app.SelectROIDropDownGH.Value, [app.SLM_roi_list.name_tag]);

lut_correction_data = app.SLM_roi_list(idx_roi).lut_correction_data;

if ~isempty(lut_correction_data)
    pointer.Value = lut_correction_data(pointer.Value+1,2);
end

holo_image = app.SLM_blank_im;
holo_image(m_idx,n_idx) = f_SLM_poiner_to_im(app, pointer, SLMm, SLMn);

app.SLM_Image_plot.CData = holo_image;
app.SLM_Image = holo_image;
            
end