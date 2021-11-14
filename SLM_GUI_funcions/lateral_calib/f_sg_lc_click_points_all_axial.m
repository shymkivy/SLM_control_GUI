function f_sg_lc_click_points_all_axial(app)

data1 = app.data.lat_calib_all;

isaxial = app.UITable.Data(:,5).Variables;

num_im = size(data1,1);

first_ord_coords = app.data.first_ord_coords;
zero_ord_coords = app.data.zero_ord_coords;

figure;
for n_file = 1:num_im
    if isaxial(n_file)
        imagesc(data1(n_file).image);
        axis tight equal;
        title(sprintf('X=%d Y=%d Z=%d, click on z reference spot', data1(n_file).X, data1(n_file).Y, data1(n_file).Z));
        [x1, y1] = ginput(1);
        first_ord_coords(n_file,:) = [x1, y1];
    end
end
close;

input_idx = find(isaxial);
[~, idx] = min(sum(app.data.input_coords(isaxial,:).^2,2));

zero_ord_coords(isaxial,:) = repmat(first_ord_coords(input_idx(idx),:), [sum(isaxial),1]);

app.data.first_ord_coords = first_ord_coords;
app.data.zero_ord_coords = zero_ord_coords;

end