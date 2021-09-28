% drag file into variables
data_dir = 'E:\data\SLM\lut_calibration';

fname = 'photodiode_lut_comb_1064L_940R_64r_11_12_20_from_linear.txt';

%% open txt

fileID = fopen([data_dir '\' fname],'r');

%[filename,x,fmt,encoding] = fopen(fileID);

data = {};
while ~feof(fileID)
    data{end+1,1} =fgetl(fileID);
end

fclose(fileID);


%%

start1 = 17;

for num_px = 0:20:255
    fov1 = zeros(17, 17);
    for n_l = 1:17
       data_ind = n_l+start1+num_px*17-1;
       txt1 =  data{data_ind};
       fov1(n_l,:) = str2double(split(txt1, ' '));
    end

    figure; imagesc(fov1);
    title(num2str(num_px));
    %caxis([0 1])
end





