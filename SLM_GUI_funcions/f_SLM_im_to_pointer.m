function holo_pointer_value = f_SLM_im_to_pointer(holo_image)
    temp_holo = uint8((rot90(holo_image, 3)/(2*pi))*255);
    holo_pointer_value = reshape(temp_holo, [],1);
end