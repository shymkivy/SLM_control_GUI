function f_SLM_BNS512OD_update(ops, image_pointer)

calllib('Blink_C_wrapper', 'Write_overdrive_image', ops.board_number, image_pointer,...
            ops.height, ops.wait_For_Trigger, ops.external_Pulse);

calllib('Blink_C_wrapper', 'ImageWriteComplete', ops.board_number, ops.timeout_ms);

end