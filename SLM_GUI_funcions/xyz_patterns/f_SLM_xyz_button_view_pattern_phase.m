function f_SLM_xyz_button_view_pattern_phase(app)

coord = f_SLM_mpl_get_coords(app, 'pattern', round(app.PatternSpinner.Value));

% get region
[m_idx, n_idx] = f_SLM_get_reg_deets(app, app.GroupRegionDropDown.Value);
SLMm = sum(m_idx);
SLMn = sum(n_idx);

holo_image = app.SLM_blank_im;
if ~isempty(coord)
    holo_image(m_idx,n_idx) =  f_SLM_gen_holo_multiplane_image(app, coord, SLMm, SLMn);
    holo_image = f_SLM_AO_add_correction(app,holo_image);
else
    holo_image = holo_image(m_idx,n_idx);
end         

f_SLM_view_hologram_phase(app, holo_image);

end