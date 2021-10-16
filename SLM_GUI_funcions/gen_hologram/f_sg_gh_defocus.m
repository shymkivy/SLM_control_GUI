function f_sg_gh_defocus(app)

% get reg
[m_idx, n_idx] = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);
SLMm = sum(m_idx);
SLMn = sum(n_idx);
beam_width = app.BeamdiameterpixEditField.Value;

idx_reg = strcmpi(app.CurrentregionDropDown.Value, [app.region_list.name_tag]);
wavelength = app.region_list(idx_reg).wavelength*1e-9;

defocus_weight = app.DeficusWeightEditField.Value*1e-6;

defocus = f_sg_DefocusPhase_YS(SLMm, SLMn,...
                app.SLM_ops.effective_NA,...
                app.SLM_ops.objective_RI,...
                wavelength, beam_width)*defocus_weight; % was wavelength*10 idk why

if app.ZerooutsideunitcircCheckBox.Value
    xlm = linspace(-SLMm/beam_width, SLMm/beam_width, SLMm);
    xln = linspace(-SLMn/beam_width, SLMn/beam_width, SLMn);
    [fX, fY] = meshgrid(xln, xlm);
    [~, RHO] = cart2pol(fX, fY);
    defocus(RHO>1) = 0;
end
            
defocus2=angle(sum(exp(1i*(defocus)),3))+pi;

holo_image = app.SLM_Image_gh_preview;
holo_image(m_idx,n_idx) = defocus2;

app.SLM_Image_plot.CData = holo_image;
app.SLM_Image_gh_preview = holo_image;

end