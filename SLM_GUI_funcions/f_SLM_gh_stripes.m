function f_SLM_gh_stripes(app)
% get roi
[m, n] = f_SLM_gh_get_roimn(app);
SLMm = m(2) - m(1) + 1;
SLMn = n(2) - n(1) + 1;

pointer = libpointer('uint8Ptr', zeros(SLMn*SLMm,1));

calllib('ImageGen', 'Generate_Stripe',...
            pointer,...
            SLMn, SLMm,...
            app.StripePixelValueEditField.Value,...
            app.StripeGrayEditField.Value,...
            app.StripePixelPerStripeEditField.Value);
        
holo_image = app.SLM_blank_im;
holo_image(m(1):m(2),n(1):n(2)) = f_SLM_poiner_to_im(app, pointer, SLMm, SLMn);

app.SLM_Image_plot.CData = holo_image;
app.SLM_Image = holo_image;
end