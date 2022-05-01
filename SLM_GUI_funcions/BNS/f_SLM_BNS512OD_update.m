function f_SLM_BNS512OD_update(ops, image)

% overdrive version, but int needs to be engauged.. regional lut during
% construct + GPU at least 
%calllib('Blink_SDK_C', 'Write_overdrive_image', ops.sdk, 1, image, ops.wait_For_Trigger, 0);

% update with no OD.. same format is as new BNS works 
calllib('Blink_SDK_C', 'Write_overdrive_image', ops.sdk, 1, image, ops.height, ops.wait_For_Trigger, ops.external_Pulse);

end