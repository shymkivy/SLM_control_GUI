function f_sg_lc_click_points_current(app)

data1 = app.data.lat_calib_all;
index1 = app.data.current_index;


figure;
imagesc(data1(index1).image);
axis tight equal;
title(sprintf('X=%d Y=%d, click on zero order spot', data1(index1).X, data1(index1).Y));
[x1, y1] = ginput(1);
zero_ord = round([x1, y1]);
title(sprintf('X=%d Y=%d, click on first order spot', data1(index1).X, data1(index1).Y));
[x1, y1] = ginput(1);
first_ord = round([x1, y1]);
close;

app.data.zero_ord_coords(index1,:) = zero_ord;
app.data.first_ord_coords(index1,:) = first_ord;

if isfield(app.data, 'zero_ord_coords')
    app.data.plot_zo.XData = app.data.zero_ord_coords(index1,1);
    app.data.plot_zo.YData = app.data.zero_ord_coords(index1,2);
end

if isfield(app.data, 'first_ord_coords')
    app.data.plot_fo.XData = app.data.first_ord_coords(index1,1);
    app.data.plot_fo.YData = app.data.first_ord_coords(index1,2);
end

end