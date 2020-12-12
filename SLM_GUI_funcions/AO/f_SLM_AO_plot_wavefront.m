function f_SLM_AO_plot_wavefront(app)

if app.ApplyAOcorrectionButton.Value
    [~, ~, ~,  reg1] = f_SLM_get_reg_deets(app, app.CurrentregionDropDown.Value);

    reg1.AO_correction = app.AOcorrectionDropDown_2.Value;
    [AO_wf, AO_params] = f_SLM_AO_compute_wf2(app, reg1);
    
    if isstruct(AO_wf)
        Z = app.current_SLM_coord.xyzp(3)*1e5;
        [dist1, idx] = min(abs(Z - [AO_wf.Z]));
        if dist1 <= 20
            AO_wf2 = AO_wf(idx).wf_out;
        else
            AO_wf2 = zeros(size(AO_wf(idx).wf_out));
        end
    else
        AO_wf2 = AO_wf;
    end
    
    
    if isempty(AO_wf2)
        AO_wf2 = app.SLM_blank_im;
        used_modes = '';
    else
        used_modes = '';%[', used modes: ' num2str(AO_wf.wf_ou AO_params.AO_correction(:,1)')];
    end
    
    figure; imagesc(AO_wf2); axis equal tight;
    title(['AO correction' used_modes]);
else
    disp('Turn on "Apply AO correction"');
end

end