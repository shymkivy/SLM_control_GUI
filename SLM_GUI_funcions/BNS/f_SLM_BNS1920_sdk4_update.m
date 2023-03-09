function f_SLM_BNS1920_sdk4_update(ops, image_pointer)

% loads image
val_write = calllib('Blink_C_wrapper', 'Write_image', ops.board_number, image_pointer,...
        ops.width*ops.height, ops.wait_For_Trigger, ops.flip_immediate,...
        ops.external_Pulse, ops.output_pulse_image_refresh, ops.timeout_ms);
% checks if image is complete
val_complete = calllib('Blink_C_wrapper', 'ImageWriteComplete', ops.board_number, ops.timeout_ms);

end