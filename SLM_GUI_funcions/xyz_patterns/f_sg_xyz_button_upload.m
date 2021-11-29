function f_sg_xyz_button_upload(app, upload_type)

%% get coords
if strcmpi(upload_type, 'custom')
    coord = f_sg_mpl_get_coords(app, upload_type);
elseif strcmpi(upload_type, 'table_selection')
    if size(app.UIImagePhaseTableSelection,1) > 0
        coord = f_sg_mpl_get_coords(app, upload_type);
    else
        coord = [];
    end
elseif strcmpi(upload_type, 'pattern')
    coord = f_sg_mpl_get_coords(app, upload_type, app.PatternSpinner.Value);
end

%% generate image
if ~isempty(coord)
    [m_idx, n_idx, reg1] = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);
    
    %% update slm im
    app.SLM_complex(m_idx, n_idx) = f_sg_xyz_gen_holo(app, coord, reg1);
    app.current_SLM_coord = coord;
    
    %% add ao corrections
    app.SLM_phase_corr = app.SLM_phase;
    if app.ApplyAOcorrectionButton.Value
        AO_phase = f_sg_AO_get_correction(app, app.CurrentregionDropDown.Value);
        
        app.SLM_ao_phase(m_idx, n_idx) = AO_phase;
        
        app.SLM_phase_corr(m_idx, n_idx) = angle(app.SLM_complex(m_idx, n_idx).*exp(1i*(AO_phase)));
    end
    
    %%
    f_sg_upload_image_to_SLM(app);
end

end