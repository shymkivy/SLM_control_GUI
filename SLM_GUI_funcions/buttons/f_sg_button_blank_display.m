function f_sg_button_blank_display(app)

app.SLM_complex = app.SLM_blank_im;
app.SLM_phase_corr = angle(app.SLM_blank_im);
app.current_SLM_coord = f_sg_mpl_get_coords(app, 'zero');

app.SLM_phase_plot.CData = app.SLM_phase_corr+pi;
app.SLM_gh_phase_preview = app.SLM_phase_corr;

f_sg_upload_image_to_SLM(app);   
disp('SLM blank uploaded');

end