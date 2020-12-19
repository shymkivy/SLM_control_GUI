function f_SLM_button_blank_display(app)

app.SLM_Image = app.SLM_blank_im;
app.SLM_Image_gh_preview = app.SLM_blank_im;
app.SLM_Image_plot.CData = app.SLM_Image;

app.current_SLM_coord = f_SLM_mpl_get_coords(app, 'zero');
app.current_SLM_AO_Image = [];

disp('SLM blank uploaded');

end