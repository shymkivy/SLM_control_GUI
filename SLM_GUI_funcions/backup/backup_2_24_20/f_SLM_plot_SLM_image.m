function f_SLM_plot_SLM_image(app)
    app.SLM_Image = single(reshape(app.SLM_Image_pointer.Value, [app.SLM_ops.width,app.SLM_ops.height]));
    app.SLM_Image = rot90(mod(app.SLM_Image, 256));
    app.SLM_Image = (app.SLM_Image/255)*(2*pi);
    app.SLM_Image_plot.CData = app.SLM_Image;
end