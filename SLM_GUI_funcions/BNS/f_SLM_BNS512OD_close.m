function ops = f_SLM_BNS512OD_close(ops)

if ops.constructed_okay.value == 0
    % Always call Delete_SDK before exiting
    if ops.SDK_created == 1
        calllib('Blink_SDK_C', 'Delete_SDK', ops.sdk);
        disp('Deleted SDK')
        ops.SDK_created = 0;
    end
end

%destruct
if libisloaded('Blink_SDK_C')
    unloadlibrary('Blink_SDK_C');
end

if libisloaded('ImageGen')
    unloadlibrary('ImageGen');
end
 
end