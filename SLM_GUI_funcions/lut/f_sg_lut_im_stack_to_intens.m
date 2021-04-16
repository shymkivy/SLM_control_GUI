function f_sg_lut_im_stack_to_intens()

figure;
plot_int = floor(size(calib_im_series,3)/6);
for n_plot = 1:6
    interval = (plot_int*(n_plot-1)+1):(plot_int*n_plot);
    subplot(2,3,n_plot);
    imagesc(mean(calib_im_series(:,:,interval),3)');axis image;
    title(sprintf('Gray pix %d-%d', interval(1), interval(end)));
end

figure;
imagesc(mean(calib_im_series,3)');axis image;
title('Select the zero point');
pt_zero_ord = ginput(1);
title('Select the first order point');
pt_first_ord = ginput(1);


pt_zero_ord = round(pt_zero_ord);
pt_first_ord = round(pt_first_ord);

ds = 35;
figure;
subplot(1,2,1);
zero_ord_im = calib_im_series(round((pt_zero_ord(1)-ds):(pt_zero_ord(1)+ds)), round((pt_zero_ord(2)-ds):(pt_zero_ord(2)+ds)),:);
imagesc(mean(zero_ord_im,3)');axis image;
title('Zero order point');
subplot(1,2,2);
first_ord_im = calib_im_series(round((pt_first_ord(1)-ds):(pt_first_ord(1)+ds)), round((pt_first_ord(2)-ds):(pt_first_ord(2)+ds)),:);
imagesc(mean(first_ord_im,3)');axis image;
title('First order point');

AI_Intensities(:, 1) = 1:size(calib_im_series,3);
AI_Intensities(:, 2) = mean(mean(zero_ord_im,1),2);
AI_Intensities(:, 3) = mean(mean(first_ord_im,1),2);



figure; plot(AI_Intensities(:,2)); hold on; plot(AI_Intensities(:,3));
legend('Zero ord', 'First ord');
title('intensities vs gray')

% dump the AI measurements to a csv file

fold_dir = [save_csv_path 'zero_ord\'];
if ~exist(fold_dir, 'dir'); mkdir(fold_dir); end
csvwrite([fold_dir  'raw' num2str(Region) '.csv'], [AI_Intensities(:, 1) AI_Intensities(:, 2)]);

fold_dir = [save_csv_path 'first_ord\'];
if ~exist(fold_dir, 'dir'); mkdir(fold_dir); end
csvwrite([fold_dir  'raw' num2str(Region) '.csv'], [AI_Intensities(:, 1) AI_Intensities(:, 3)]);

AI_stack{Region+1} = AI_Intensities;
if save_raw_stack
    calib_im_stack{Region+1} = calib_im_series;
    coord_stack{Region+1} = [pt_zero_ord; pt_first_ord];
end



end