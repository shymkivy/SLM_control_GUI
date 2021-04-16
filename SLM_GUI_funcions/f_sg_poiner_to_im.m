function im_out = f_sg_poiner_to_im(pointer_in, SLMm, SLMn)

holo_image = double(mod(pointer_in.Value, 256))/255*2*pi;
im_out = rot90(reshape(holo_image,SLMn,SLMm),1);

end