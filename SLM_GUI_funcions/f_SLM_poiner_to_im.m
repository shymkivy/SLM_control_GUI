function im_out = f_SLM_poiner_to_im(app, pointer_in, SLMm, SLMn)

if ~exist('SLMm', 'var')
    SLMm = app.SLM_ops.height;
    SLMn = app.SLM_ops.width;
end

holo_image = double(mod(pointer_in.Value, 256))/255*2*pi;
im_out = rot90(reshape(holo_image,SLMn,SLMm),1);

end