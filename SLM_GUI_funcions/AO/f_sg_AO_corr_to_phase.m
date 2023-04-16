function phase = f_sg_AO_corr_to_phase(correction, ao_temp)

phase = zeros(ao_temp.reg1.SLMm, ao_temp.reg1.SLMn);
for n_corr = 1:size(correction,1)
    phase = phase + ao_temp.all_modes(:,:,correction(n_corr,1))*correction(n_corr,2);
end

end