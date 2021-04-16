function f_SLM_BNS_update_512_OD(ops, image)

% % loads image for new BNS 1920
% calllib('Blink_C_wrapper', 'Write_image', ops.board_number, image, ops.width*ops.height, ops.wait_For_Trigger, ops.external_Pulse, ops.timeout_ms);
% % checks if image is complete
% calllib('Blink_C_wrapper', 'ImageWriteComplete', ops.board_number, ops.timeout_ms);

calllib('Blink_SDK_C', 'Write_overdrive_image', ops.sdk, 1, image, ops.wait_For_Trigger, 0);
 
end