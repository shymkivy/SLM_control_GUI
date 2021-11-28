function f_sg_lc_click_points_all_lateral(app)

data1 = app.data.lat_calib_all;

islateral = app.UITable.Data(:,4).Variables;

num_im = size(data1,1);

zero_ord_coords = zeros(num_im,2);
first_ord_coords = zeros(num_im,2);
figure;
for n_file = 1:num_im
    if islateral(n_file)
        imagesc(data1(n_file).image);
        axis tight equal;
        title(sprintf('X=%d Y=%d Z=%d, click on zero order spot', data1(n_file).X, data1(n_file).Y, data1(n_file).Z));
        [x1, y1] = ginput(1);
        zero_ord_coords(n_file,:) = [x1, y1];
        title(sprintf('X=%d Y=%d Z=%d, click on first order spot', data1(n_file).X, data1(n_file).Y, data1(n_file).Z));
        [x1, y1] = ginput(1);
        first_ord_coords(n_file,:) = [x1, y1];
    end
end
close;

app.data.zero_ord_coords = zero_ord_coords;
app.data.first_ord_coords = first_ord_coords;

end