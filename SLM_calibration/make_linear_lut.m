% bns linear lut is 11 bit not 12? (0-2047)


lut_min = 500; % 940 min
lut_max = 1580; % 1064 max



path1 = 'E:\data\SLM\lut_calibration\lut_940_slm5221_maitai_1r_11_05_20_15h_19m\first_ord\slm5221_at940_1r_11_5_20.lut';
data = load(path1);
figure; plot(data(:,2))

save('temp.lut', 'data')