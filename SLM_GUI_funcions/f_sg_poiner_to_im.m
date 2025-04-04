function im_out = f_sg_poiner_to_im(pointer_in, SLMm, SLMn)

holo_image = double(mod(pointer_in.Value, 256))/256*2*pi;
im_out = reshape(holo_image,SLMn,SLMm)';

end