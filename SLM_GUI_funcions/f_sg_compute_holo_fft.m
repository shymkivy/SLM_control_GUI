function [im_amp, xy_axis] = f_sg_compute_holo_fft(reg1, holo_image, defocus_dist)

dims = size(holo_image);
siz = max(dims);

phase_sq = zeros(siz,siz);

% beam shape
Lx = linspace(-siz/reg1.phase_diameter, siz/reg1.phase_diameter, siz);
sigma = 1;

%Lx = linspace(-(siz-1)/2,(siz-1)/2,siz);
%sigma = reg1.beam_diameter/2; 			% beam waist/2

[c_X, c_Y] = meshgrid(Lx, Lx);
x0 = 0;                 % beam center location
y0 = 0;                 % beam center location
A = 1;                  % peak of the beam 
res = ((c_X-x0).^2 + (c_Y-y0).^2)./(2*sigma^2);
pupil_amp = A  * exp(-res);

pupil_mask = false(siz,siz);
pupil_mask((1 + (siz - dims(1))/2):(siz - (siz - dims(1))/2),(1 + (siz - dims(2))/2):(siz - (siz - dims(2))/2)) = 1;

pupil_amp(~pupil_mask) = 0;

defocus = f_sg_DefocusPhase(reg1);

defocus2 = phase_sq;
defocus2(pupil_mask) = defocus;

holo_image1 = phase_sq;
holo_image1(pupil_mask) = holo_image;

SLM_complex_wave=pupil_amp.*(exp(1i.*holo_image1)./exp(1i.*(defocus_dist.*defocus2*1e-6)));

im1 = fftshift(fft2(SLM_complex_wave));
im_amp = abs(im1)/sum(abs(SLM_complex_wave(:)));

% if app.fftampsquaredCheckBox.Value
%im_amp = im_amp.^2;
% end

xy_axis = linspace(-(siz-1)/2, (siz-1)/2, siz)/2;

end