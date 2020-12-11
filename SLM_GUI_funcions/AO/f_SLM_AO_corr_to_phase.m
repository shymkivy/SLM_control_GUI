function phase = f_SLM_AO_corr_to_phase(correction,all_modes)

[SLMm, SLMn,~] = size(all_modes);
phase = zeros(SLMm, SLMn);
for n_corr = 1:size(correction,1)
    phase = phase + all_modes(:,:,correction(n_corr,1))*correction(n_corr,2);
end

%figure; imagesc(phase)
end