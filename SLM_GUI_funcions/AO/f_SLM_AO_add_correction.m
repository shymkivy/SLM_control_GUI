function SLM_image_out = f_SLM_AO_add_correction(app, SLM_image_in)

if app.ApplyAOcorrectionButton.Value
    % this first one is wrong, should be multiplied not superimposed
    %SLM_image_out = angle(exp(1i*(SLM_image_in-pi))+exp(1i*(app.SLM_AO_Image-pi))) + pi;
    SLM_image_out = angle(exp(1i*(SLM_image_in-pi+app.SLM_AO_Image-pi))) + pi;
else
    SLM_image_out = SLM_image_in;
end

end