function f_SLM_BNS512OD_update(ops, image)

% % loads image for new BNS 1920
% calllib('Blink_C_wrapper', 'Write_image', ops.board_number, image, ops.width*ops.height, ops.wait_For_Trigger, ops.external_Pulse, ops.timeout_ms);
% % checks if image is complete
% calllib('Blink_C_wrapper', 'ImageWriteComplete', ops.board_number, ops.timeout_ms);


% this may need to be changed back to image or array pointer

% from seans code
% pass an array pointer down to the C++ code
% pImage = libpointer('uint8Ptr', image); 
% calllib('SLMlib', 'WriteImage', SLM, pImage, 512);

% from weiji code but sent as double

%calllib('Blink_SDK_C', 'Write_overdrive_image', ops.sdk, 1, image, ops.wait_For_Trigger, 0);

% image2 = int8(f_sg_poiner_to_im(image, ops.height, ops.width)/2/pi*255);
% pImage = libpointer('uint8Ptr', image2);

%same format is ok as new
calllib('Blink_SDK_C', 'Write_image', ops.sdk, 1, image, ops.height, ops.wait_For_Trigger, 0);

end