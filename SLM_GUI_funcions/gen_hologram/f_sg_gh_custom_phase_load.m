function f_sg_gh_custom_phase_load(app)

[fpath, fname, ext] = fileparts(app.ImagepathEditField.Value);

if strcmpi(ext, '.mat')
    im_data = load([fpath '\' fname ext]);
    fieldnames1 = fieldnames(im_data);
    im = im_data.(fieldnames1{1});
else
    try
        im = imread([fpath '\' fname ext]);
    catch
        uialert(app.UIFigure, 'File needs to be either mat or some image format readable by imread()','Error');
    end
end

if strcmpi(app.PhaseformatDropDown.Value, 'Preprocessed to uint8')
    if ~strcmpi(class(im), 'uint8')
        uialert(app.UIFigure, 'Preprocessed image must be uint8 format','Error');
        holo_image = [];
    else
        im2 = double(mod(im, 256))/255*2*pi;
        holo_image = exp(1i*(im2-pi));
    end
elseif strcmpi(app.PhaseformatDropDown.Value, 'Radians')
    holo_image = exp(1i*(im-pi));
end

if ~sum(size(holo_image) == [app.SLM_ops.height app.SLM_ops.width])==2
    uialert(app.UIFigure, sprintf('Image size must be %d x %d', app.SLM_ops.height, app.SLM_ops.width),'Error');
end

if ~isempty(holo_image)
    app.SLM_Image_plot.CData = angle(holo_image)+pi; % in 0-2pi format
    app.SLM_Image_gh_preview = holo_image; % complex format
end

end