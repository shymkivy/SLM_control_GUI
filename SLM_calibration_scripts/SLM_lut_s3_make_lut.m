%% compute LUT for SLM
% so far I like this better than the one from bns 
% lut pipeline step 3/3
% yuriy

clear;
close all

%%
path1 = 'E:\data\SLM\lut_calibration\';
fname = 'lut_940_slm5221_maitai_1r_11_05_20_15h_19m';

load_path_fo = [path1 fname '\first_ord'];
load_path_zo = [path1 fname '\zero_ord'];

%%
params.two_photon_correction = 1; % since 2pFl ~ I^2, will take sqrt
params.smooth_win = 10;
params.order_use = 1;

params.manual_peak_selection = 1;
params.plot_stuff = 1;


%% first order 
% 
data_fo = csvread([load_path_fo '\raw0.csv']);

[px_fo, phi_fo] = f_lut_fit_gamma(data_fo, 1, params);

%% zero order 

data_zo = csvread([load_path_zo '\raw0.csv']);

[px_zo, phi_zo] = f_lut_fit_gamma(data_zo, 0, params);

%%
figure; hold on;
plot(px_fo, phi_fo);
plot(px_zo, phi_zo);
title('fo vs zo')
legend('first ord', 'zero ord', 'Location', 'southeast');

%% need conversion from 0-255 to adjusted
if params.order_use
    x = phi_fo*255;
    v = px_fo;
    name_tag = '_fo.mat';
else
    x = phi_zo*255;
    v = px_zo;
    name_tag = '_zo.mat';
end

xq = (0:255)';
vq = interp1(x, v, xq);

LUT_correction = [xq, vq];

%%
save_input = input('Save data? [y]:', 's');

if strcmpi(save_input, 'y')
    params.fname = fname;
    params = rmfield(params , 'plot_stuff');
    save([path1,'computed_', fname, name_tag], 'LUT_correction', 'params');
end
