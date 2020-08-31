function im_out = f_SLM_poiner_to_im(app, pointer_in)

holo_image = double(mod(pointer_in.Value, 256))/255*2*pi;
im_out = rot90(reshape(holo_image,app.SLM_ops.width,app.SLM_ops.height),1);

end