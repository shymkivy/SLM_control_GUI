function [im_amp, x_lab, y_lab] = f_sg_compute_holo_fft(reg1, holo_image, defocus_dist, AO_phase, use_gauss_amp)

ph_d = reg1.phase_diameter;

%siz = max(dims);
%phase_sq = zeros(dims);

% beam shape
pupil_amp2 = f_sg_get_beam_amp(reg1, use_gauss_amp);

% defocus
defocus = f_sg_DefocusPhase2(reg1);
defocus_phase = defocus_dist*1e-6.*defocus;
if exist("AO_phase", 'var')
    if ~isempty(AO_phase)
        defocus_phase = defocus_phase + AO_phase;
    end
end
defocus_cpx = exp(1i.*defocus_phase);

SLM_complex_wave=pupil_amp2.*exp(1i.*holo_image);

im_amp = abs(fftshift(fft2(SLM_complex_wave./defocus_cpx)).^2);

%sum(im_amp(:))
%im_amp = abs(im1)/prod(dims);

% fft output, first value is baseline (0, 0), the middle of remainder is N/2 freq
dims = size(im_amp);
x_lab = round(((1:dims(2))-(dims(2)/2)-1)/2/dims(2)*ph_d,2);
y_lab = round(((1:dims(1))-(dims(1)/2)-1)/2/dims(1)*ph_d,2);

end
