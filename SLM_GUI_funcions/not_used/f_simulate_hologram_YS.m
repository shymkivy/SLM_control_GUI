function planes = f_simulate_hologram_YS(z_offsets, phase, amplitude)
% planes in um from 0 [-5 0 5]

planes = zeros(size(phase,1),size(phase,2), numel(z_offsets));

SLMm = size(phase,1);
SLMn = size(phase,2);
illuminationWavelength = 1064e-9;
objectiveRI = 1.3;
objectiveNA = 1;


defocus = f_SLMMicroscope_DefocusPhase( SLMm, SLMn, objectiveNA, objectiveRI, illuminationWavelength );


for n_plane = 1:numel(z_offsets)
    temp_phase = amplitude .* exp(1i*(phase + defocus*z_offsets(n_plane)));
    planes(:,:,n_plane) = abs(fftshift(fft2(temp_phase)));
end

%im_out = fftshift(fft2(amplitude.*exp(1i.*angle(phase))));
%figure; imagesc(abs(im_out));

% figure; imagesc(planes(:,:,n_plane))

end





