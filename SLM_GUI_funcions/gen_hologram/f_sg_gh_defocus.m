function f_sg_gh_defocus(app)

% get reg
reg1 = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);

defocus_weight = app.DeficusWeightEditField.Value*1e-6; % convert to um

% zernike way
defocus_phase = f_sg_DefocusPhase(reg1)*defocus_weight;

% defocus equation
defocus_phase2 = f_sg_DefocusPhase2(reg1)*defocus_weight;

if reg1.zero_outside_phase_diameter
    defocus_phase(~reg1.holo_mask) = 0;
end

%sum(sum(defocus_phase2*2/reg1.SLMm*2/reg1.SLMn))
            
defocus_phase2=angle(sum(exp(1i*(defocus_phase)),3));

app.SLM_gh_phase_preview(reg1.m_idx, reg1.n_idx) = defocus_phase2;
app.SLM_phase_plot.CData = app.SLM_gh_phase_preview+pi;

end