function f_SLM_blank_display(app)

app.SLM_Image = app.SLM_blank_im;
app.current_SLM_coord = f_SLM_mpl_get_coords(app, 'zero');
app.SLM_Image_plot.CData = app.SLM_Image;
app.UITablecurrentcoord.Data = app.current_SLM_coord.xyzp;
f_SLM_upload_image_to_SLM(app);
disp('SLM blank uploaded');

end