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

holo_image2 = holo_image - defocus_dist.*defocus*1e-6;
sim_crosstalk = 1;
bin_fac = 5;

if sim_crosstalk
    holo_image_rep = f_repmat_xy(holo_image2, bin_fac);
    holo_image3 = f_smooth_nd(holo_image_rep, [2 2]);

    pupil_amp2 = f_repmat_xy(pupil_amp, bin_fac)/bin_fac^2;

    % temp_cpx = exp(1i*holo_image2);
    % mean_off_mag_pre = abs(mean(mean(temp_cpx)));
    % for n = 1:10
    %     mean_off = mean(mean(temp_cpx));
    %     temp_cpx = temp_cpx - mean_off;
    % end
    % mean_off_mag_post = abs(mean(mean(temp_cpx)));
    % 
    % holo_image3 = angle(temp_cpx);
    % temp_cpx = exp(1i*holo_image3);
    % mean_off_mag_post2 = abs(mean(mean(temp_cpx)));
else
    holo_image3 = holo_image2;
    pupil_amp2 = pupil_amp;
end
SLM_complex_wave=pupil_amp2.*exp(1i.*(holo_image3));

im1 = fftshift(fft2(SLM_complex_wave));
im_amp = abs(im1)/prod(dims);

if sim_crosstalk
    %im_amp = f_bin_sum(im_amp, bin_fac);
    
    dims2 = size(im_amp);
    
    idx1 = (dims2(1)/2 - dims(1)/2+1):(dims2(1)/2 + dims(1)/2);
    idx2 = (dims2(2)/2 - dims(2)/2+1):(dims2(2)/2 + dims(2)/2);
    im_amp = im_amp(idx1 ,idx2);
    
end
% figure()
% imagesc(im_amp)

%x_lab = linspace(-(ph_d-1)/2, (ph_d-1)/2, dims(2)-1)/2;
%y_lab = linspace(-(ph_d-1)/2, (ph_d-1)/2, dims(1)-1)/2;

% fft output, first value is baseline (0, 0), the middle of remainder is N/2 freq

dims = size(im_amp);

x_lab = round(((1:dims(2))-(dims(2)/2)-1)/2/dims(2)*ph_d,2);
y_lab = round(((1:dims(1))-(dims(1)/2)-1)/2/dims(1)*ph_d,2);

end

function mat_out = f_repmat_xy(mat_in, num_rep)

[d1, d2] = size(mat_in);
holo_image2 = reshape(permute(repmat(mat_in, [1, 1, num_rep]), [3, 1, 2]), [d1*num_rep, d2]);
[d1, d2] = size(holo_image2);
mat_out = reshape(permute(repmat(holo_image2, [1, 1, num_rep]), [3, 2, 1]), [d2*num_rep, d1])';

end

function mat_out = f_bin_sum(mat_in, num_bin)

[d1, d2] = size(mat_in);
mat_in2 = reshape(sum(reshape(mat_in, [num_bin, d1/num_bin, d2]),1), [d1/num_bin, d2]);
mat_out = reshape(sum(reshape(mat_in2', [num_bin, d2/num_bin, d1/num_bin]),1), [d2/num_bin, d1/num_bin])';

end
