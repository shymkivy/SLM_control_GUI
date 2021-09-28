clear;
close all;

addpath('C:\Users\ys2605\Desktop\stuff\SLM_GUI\SLM_control_GUI\SLM_calibration\calibration_functions');

%% load stuff for testing

fname = 'C:\Users\ys2605\Desktop\stuff\SLM_GUI\SLM_control_GUI\SLM_calibration\lut_calibration\linear2.lut';
lut_array = f_SLM_read_lut(fname);

%% generate smaller linear lut version for higher sampling of voltage values
% bns linear lut is 11 bit not 12? (0-2047)

fname_save = 'C:\Users\ys2605\Desktop\stuff\SLM_GUI\SLM_control_GUI\SLM_calibration\lut_calibration\linear_cut_940_1054.lut';

n_vals = 256;

lut_min = 500; % 940 min
lut_max = 1600; % 1064 max

lut_array = zeros(n_vals,2);

lut_array(:,1) = 0:(n_vals-1);
lut_array(:,2) = round(linspace(lut_min, lut_max, n_vals));


f_SLM_write_lut(lut_array, fname_save)


% data = load(path1);
% figure; plot(data(:,2))
% 
% 
% save('temp.lut', 'data')