function f_sg_lc_plot_image(app, indices)

im1 = app.data.lat_calib_all(indices(1,1)).image;

app.data.current_index = indices(1,1);
app.data.plot_im.CData = im1;

if isfield(app.data, 'zero_ord_coords')
    app.data.plot_zo.XData = app.data.zero_ord_coords(indices(1,1),1);
    app.data.plot_zo.YData = app.data.zero_ord_coords(indices(1,1),2);
end

if isfield(app.data, 'first_ord_coords')
    app.data.plot_fo.XData = app.data.first_ord_coords(indices(1,1),1);
    app.data.plot_fo.YData = app.data.first_ord_coords(indices(1,1),2);
end

end