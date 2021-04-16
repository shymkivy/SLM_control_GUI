function SLM_image_out = f_sg_AO_add_correction(app, SLM_image_in, AO_wf)

if app.ApplyAOcorrectionButton.Value
    if ~isempty(AO_wf)
        SLM_image_out = SLM_image_in.*exp(1i*(AO_wf));
    else
        SLM_image_out = SLM_image_in;
    end
else
    SLM_image_out = SLM_image_in;
end

end