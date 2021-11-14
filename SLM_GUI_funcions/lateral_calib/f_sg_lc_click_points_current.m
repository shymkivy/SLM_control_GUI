function f_sg_lc_click_points_current(app)

data1 = app.data.lat_calib_all;
index1 = app.data.current_index;

if app.UITable.Data(index1,4).Variables
    figure;
    imagesc(data1(index1).image);
    axis tight equal;
    title(sprintf('X=%d Y=%d Z=%d, click on zero order spot', data1(index1).X, data1(index1).Y, data1(index1).Z));
    [x1, y1] = ginput(1);
    zero_ord = [x1, y1];
    title(sprintf('X=%d Y=%d Z=%d, click on first order spot', data1(index1).X, data1(index1).Y, data1(index1).Z));
    [x1, y1] = ginput(1);
    first_ord = [x1, y1];
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
    
if app.UITable.Data(index1,5).Variables
    
    figure;
    imagesc(data1(n_file).image);
    axis tight equal;
    title(sprintf('X=%d Y=%d Z=%d, click on z reference spot', data1(n_file).X, data1(n_file).Y, data1(n_file).Z));
    [x1, y1] = ginput(1);
    z_shift_coord = [x1, y1];
    close;

    app.data.z_shift_coords(index1,:) = z_shift_coord;
end

end