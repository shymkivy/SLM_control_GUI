function SLM_image_out = f_sg_AO_add_correction(SLM_image_in, AO_wf)

if ~isempty(AO_wf)
    SLM_image_out = SLM_image_in.*exp(1i*(AO_wf));
else
    SLM_image_out = SLM_image_in;
end

end