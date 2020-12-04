function SLM_image_out = f_SLM_AO_add_correction(app, SLM_image_in, AO_wf)

if app.ApplyAOcorrectionButton.Value
    if ~isempty(AO_wf)
        SLM_image_out = angle(exp(1i*(SLM_image_in+AO_wf-pi))) + pi;
    else
        SLM_image_out = SLM_image_in;
    end
else
    SLM_image_out = SLM_image_in;
end

end