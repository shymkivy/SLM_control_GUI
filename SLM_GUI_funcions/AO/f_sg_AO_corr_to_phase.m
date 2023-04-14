function phase = f_sg_AO_corr_to_phase(correction, ao_params)

phase = zeros(ao_params.region.SLMm, ao_params.region.SLMn);
for n_corr = 1:size(correction,1)
    phase = phase + ao_params.all_modes(:,:,correction(n_corr,1))*correction(n_corr,2);
end

end