function SLM_image_out = f_SLM_AO_add_correction(app, SLM_image_in, AO_wf)

if app.ApplyAOcorrectionButton.Value
    if ~isempty(AO_wf)
        if isstruct(AO_wf)
            Z = mean(app.current_SLM_coord.xyzp(:,3)*1e5);
            [dist1, idx] = min(abs(Z - [AO_wf.Z]));
            if dist1 <= 20
                AO_wf2 = AO_wf(idx).wf_out;
            else
                AO_wf2 = zeros(size(AO_wf(idx).wf_out));
            end
        else
            AO_wf2 = AO_wf;
        end
        SLM_image_out = SLM_image_in.*exp(1i*(AO_wf2));
    else
        SLM_image_out = SLM_image_in;
    end
else
    SLM_image_out = SLM_image_in;
end

end