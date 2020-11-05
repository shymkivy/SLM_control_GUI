function f_SLM_gh_gen_holo(app, pattern)

% get roi
[m, n] = f_SLM_gh_get_roimn(app);
SLMm = m(2) - m(1) + 1;
SLMn = n(2) - n(1) + 1;

image1 = f_SLM_gh_gen_image(app, pattern, SLMm, SLMn);

holo_image = app.SLM_blank_im;
holo_image(m(1):m(2),n(1):n(2)) = image1;

app.SLM_Image_plot.CData = holo_image;
app.SLM_Image = holo_image;
            
end