function [im_amp, x_lab, y_lab] = f_sg_compute_holo_fft(reg1, holo_image, defocus_dist)

defocus = f_sg_DefocusPhase(reg1);

dims = size(holo_image);

%siz = max(dims);
%phase_sq = zeros(dims);

% beam shape
ph_d = reg1.phase_diameter;

Lx = linspace(-dims(2)/ph_d, dims(2)/ph_d, dims(2));
Ly = linspace(-dims(1)/ph_d, dims(1)/ph_d, dims(1));
sigma = 1;

%Lx = linspace(-(siz-1)/2,(siz-1)/2,siz);
%sigma = reg1.beam_diameter/2; 			% beam waist/2

[c_X, c_Y] = meshgrid(Lx, Ly);
x0 = 0;                 % beam center location
y0 = 0;                 % beam center location
A = 1;                  % peak of the beam 
res = ((c_X-x0).^2 + (c_Y-y0).^2)./(2*sigma^2);
pupil_amp = A  * exp(-res);

%pupil_mask = false(siz,siz);
%pupil_mask((1 + (siz - dims(1))/2):(siz - (siz - dims(1))/2),(1 + (siz - dims(2))/2):(siz - (siz - dims(2))/2)) = 1;

%pupil_amp(~pupil_mask) = 0;

%defocus2 = phase_sq;
%defocus2(pupil_mask) = defocus;

%holo_image1 = phase_sq;
%holo_image1(pupil_mask) = holo_image;

SLM_complex_wave=pupil_amp.*exp(1i.*(holo_image - defocus_dist.*defocus*1e-6));

im1 = fftshift(fft2(SLM_complex_wave));
im_amp = abs(im1)/prod(dims);

% figure()
% imagesc(im_amp)

%x_lab = linspace(-(ph_d-1)/2, (ph_d-1)/2, dims(2)-1)/2;
%y_lab = linspace(-(ph_d-1)/2, (ph_d-1)/2, dims(1)-1)/2;

% fft output, first value is baseline (0, 0), the middle of remainder is N/2 freq
x_lab = round(((1:dims(2))-(dims(2)/2)-1)/2/dims(2)*ph_d,2);
y_lab = round(((1:dims(1))-(dims(1)/2)-1)/2/dims(1)*ph_d,2);

end