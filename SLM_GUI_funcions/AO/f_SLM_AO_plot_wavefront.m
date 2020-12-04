function f_SLM_AO_plot_wavefront(app)

if app.ApplyAOcorrectionButton.Value
    [~, ~, ~,  reg1] = f_SLM_get_reg_deets(app, app.AOregionDropDown.Value);

    reg1.AO_correction = app.AOcorrectionDropDown_2.Value;
    [AO_wf, AO_params] = f_SLM_AO_compute_wf(app, reg1);
    
    if isempty(AO_wf)
        AO_wf = app.SLM_blank_im;
    end
    
    figure; imagesc(AO_wf); axis equal tight;
    title(['AO correction, used modes: ' num2str(AO_params.AO_correction(:,1)')]);
else
    disp('Turn on "Apply AO correction"');
end

end