% this scrip is for taking a Wavefront Correction Image at particular
% wavelength, and modifying it to work at another wavelength. All you need
% to do is unwrap the wavefront and scale

close all;
clear;

fdir = 'C:\Users\ys2605\Desktop\stuff\SLM_GUI\SLM_calibration\lut_calibration';
WFC_in_fname = 'slm6714_at1064_75C_WFC.bmp';
WFC_out_fname = 'slm6714_at940_75C_WFC.bmp';

WFC_fpath = [ fdir, '\' WFC_in_fname];
WFC_im = imread(WFC_fpath);

width = 1024;
height = 1024;

wavelength_in = 1064;
wavelength_out = 940;

%im1 = double(reshape(pointer.Value, width, height))/256*2*pi;
% transform back
WFC1 = double(WFC_im)/256*2*pi;

% matlab unwrap does not work sometimes
%WFC2 = unwrap(WFC1);

% new unwrap
tol1 = 2*pi - 1;
rel_offset = f_compute_holo_offset(WFC1, tol1);
WFC2 = WFC1 + rel_offset*2*pi;

holo_corr = (WFC2)*1064/940;     % convert to new wavelength
WFC_corr = angle(exp(1i * ((holo_corr)-pi)))+pi;

WFC_corr_lut = uint8(WFC_corr/2/pi*256);

imwrite(WFC_corr_lut,[ fdir, '\' WFC_out_fname]);

figure(); imagesc(WFC1); title(sprintf('original WFC at %d', wavelength_in));
figure(); imagesc(WFC2); title(sprintf('unwrapped WFC at %d', wavelength_in));
figure(); imagesc(WFC_corr); title(sprintf('new WFC at %d', wavelength_out));
figure(); imagesc(WFC_corr_lut); title(sprintf('new WFC lut at %d', wavelength_out));



% was trying another method 
% coord_cent = [512, 512];
% period1 = 20;
% WFC_in = WFC1;
% 
% WFC_out = WFC_in;
% im_bord1 = WFC_out<pi;
% pix1 = [1, 1];
% has_breaks = f_check_holo_breaks(pix1, coord_cent, im_bord1, period1);
% 
% index_in = false(height, width);
% for py = 1:height
%     for px = 1:width
%         pix1 = [py, px];
% 
%         has_breaks = f_check_holo_breaks(pix1, coord_cent, im_bord1, period1);
%         if ~has_breaks
%             index_in(py, px) = 1;
%         end   
%     end
% end
% WFC_out(index_in) = WFC_out(index_in) + 2*pi;
% WFC_in(index_in) = 0;
