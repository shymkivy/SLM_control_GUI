function f_SLM_initialize_GUI_params(app)
    app.SLMheightEditField.Value = app.SLM_ops.height;
    app.SLMwidthEditField.Value = app.SLM_ops.width;
    app.blank_SLM_image = zeros(app.SLM_ops.height, app.SLM_ops.width);

    % Fresnel lens
    app.FresCenterXEditField.Value = app.SLM_ops.width/2;
    app.FresCenterYEditField.Value = app.SLM_ops.height/2;
    app.FresRadiusEditField.Value = app.SLM_ops.height/2;
    app.FresPowerEditField.Value = 1;
    app.FresCylindricalCheckBox.Value = 1;
    app.FresHorizontalCheckBox.Value = 0;

    % Blazed grating
    app.BlazPeriodEditField.Value = 128;
    app.BlazIncreasingCheckBox.Value = 1;
    app.BlazHorizontalCheckBox.Value = 0;

    % Stripes
    app.StripePixelPerStripeEditField.Value = 8;
    app.StripePixelValueEditField.Value = 0;
    app.StripeGrayEditField.Value = 255;
    
    % zernike
    app.CenterXEditField.Value = floor(app.SLM_ops.width/2);
    app.CenterYEditField.Value = floor(app.SLM_ops.height/2);
    app.RadiusEditField.Value = min([app.SLM_ops.height, app.SLM_ops.height])/2;
    
    % Multiplane imaging
    app.UIImagePhaseTable.Data = table();
    
    % AO zernike table
    app.ZernikeListTable.Data = table();
    f_SLM_AO_fill_modes(app);
    
    % initialize blank image
    app.BlankPixelValueEditField.Value = 0;
    app.SLM_Image_pointer = f_SLM_initialize_pointer(app);
    app.ViewHologramImage_pointer = f_SLM_initialize_pointer(app);
    app.SLM_blank_pointer = f_SLM_initialize_pointer(app);

    app.SLM_Image = single(reshape(app.SLM_Image_pointer.Value, [app.SLM_ops.width,app.SLM_ops.height]));
    app.SLM_Image = rot90(mod(app.SLM_Image, 256));
    app.SLM_Image = (app.SLM_Image/255)*(2*pi);
    app.SLM_Image_plot = imagesc(app.UIAxesGenerateHologram, app.SLM_Image);
    axis(app.UIAxesGenerateHologram, 'tight');
    caxis(app.UIAxesGenerateHologram, [0 2*pi]);
    
    % initialize DAQ
    f_SLM_initialize_DAQ(app);
end