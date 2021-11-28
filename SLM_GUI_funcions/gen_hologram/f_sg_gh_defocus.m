function f_sg_gh_defocus(app)

% get reg
[m_idx, n_idx, reg1] = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);
SLMm = sum(m_idx);
SLMn = sum(n_idx);
beam_diameter = reg1.beam_diameter;
wavelength = reg1.wavelength*1e-9;

defocus_weight = app.DeficusWeightEditField.Value*1e-6; % convert to um

defocus = f_sg_DefocusPhase(SLMm, SLMn,...
                app.SLM_ops.effective_NA,...
                app.SLM_ops.objective_RI,...
                wavelength, beam_diameter)*defocus_weight; % was wavelength*10 idk why

if app.ZerooutsideunitcircCheckBox.Value
    defocus(reg1.holo_mask) = 0;
end
            
defocus2=angle(sum(exp(1i*(defocus)),3))+pi;

holo_image = app.SLM_Image_gh_preview;
holo_image(m_idx,n_idx) = defocus2;

app.SLM_Image_plot.CData = holo_image;
app.SLM_Image_gh_preview = holo_image;

end