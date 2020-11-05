function f_SLM_holo_to_im(app, pointer, SLMm, SLMn)

holo_image = app.SLM_blank_im;
holo_image(m(1):m(2),n(1):n(2)) = f_SLM_poiner_to_im(app, pointer, SLMm, SLMn);

app.SLM_Image_plot.CData = holo_image;
app.SLM_Image = holo_image;

end