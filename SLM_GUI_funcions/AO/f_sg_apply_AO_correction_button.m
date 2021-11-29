function f_sg_apply_AO_correction_button(app)

%% compute all corrections (also maybe not needed, only during updates?)
for n_reg = 1:numel(app.region_list) 
    app.region_obj_params(n_reg).AO_wf = f_sg_AO_compute_wf(app, app.region_obj_params(n_reg));
end

%% upload current correction

% reset the phase
app.SLM_phase_corr = app.SLM_phase;

if app.ApplyAOcorrectionButton.Value
    % refresh local (maybe not needed)
    [m_idx, n_idx] = f_sg_get_reg_deets(app,reg_name);
    AO_phase = f_sg_AO_get_correction(app, app.CurrentregionDropDown.Value);
    app.SLM_ao_phase(m_idx, n_idx) = AO_phase;
    
    % apply ao to full
    app.SLM_phase_corr = angle(app.SLM_complex.*exp(1i*(app.SLM_ao_phase)));
end

%% upload slm image
f_sg_upload_image_to_SLM(app);

if app.ApplyAOcorrectionButton.Value
    app.InitializeAOLamp.Color = [0.00,1.00,0.00];
else
    app.InitializeAOLamp.Color = [0.80,0.80,0.80];
    app.current_SLM_AO_Image = [];
end

end