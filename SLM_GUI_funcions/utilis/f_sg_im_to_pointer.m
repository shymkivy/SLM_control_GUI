function holo_pointer_value = f_sg_im_to_pointer(holo_image)

temp_holo = uint8((holo_image/(2*pi))*256);
holo_pointer_value = reshape(temp_holo', [],1);

end