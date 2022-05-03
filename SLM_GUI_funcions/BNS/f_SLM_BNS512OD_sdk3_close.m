function ops = f_SLM_BNS512OD_sdk3_close(ops)

% Always call Delete_SDK before exiting
if ops.SDK_created == 1
    calllib('Blink_SDK_C', 'SLM_power', ops.sdk, 0);
    calllib('Blink_SDK_C', 'Delete_SDK', ops.sdk);
    disp('Deleted SDK')
    ops.SDK_created = 0;
end

%destruct
if libisloaded('Blink_SDK_C')
    unloadlibrary('Blink_SDK_C');
end

if libisloaded('ImageGen')
    unloadlibrary('ImageGen');
end
 
end