function f_SLM_gh_gen_holo(app, pattern)

% get roi
[m, n] = f_SLM_gh_get_roimn(app);
SLMm = m(2) - m(1) + 1;
SLMn = n(2) - n(1) + 1;

pointer = f_SLM_gh_gen_image(app, pattern, SLMm, SLMn);

% lut correction
idx_roi = strcmpi(app.SelectROIDropDownGH.Value, [app.SLM_roi_list.name_tag]);
idx_lut = strcmpi(app.SLM_ops.lut_names, app.SLM_roi_list(idx_roi).lut_fname);
lut_conv_data = round(app.SLM_ops.lut_data{idx_lut});
pointer.Value = lut_conv_data(pointer.Value+1,2);

holo_image = app.SLM_blank_im;
holo_image(m(1):m(2),n(1):n(2)) = f_SLM_poiner_to_im(app, pointer, SLMm, SLMn);

app.SLM_Image_plot.CData = holo_image;
app.SLM_Image = holo_image;
            
end