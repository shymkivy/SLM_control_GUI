function f_SLM_BNS1920_update(ops, image_pointer)

% loads image
calllib('Blink_C_wrapper', 'Write_image', ops.board_number, image_pointer, ops.width*ops.height, ops.wait_For_Trigger, ops.external_Pulse, ops.timeout_ms);
% checks if image is complete
calllib('Blink_C_wrapper', 'ImageWriteComplete', ops.board_number, ops.timeout_ms);

end