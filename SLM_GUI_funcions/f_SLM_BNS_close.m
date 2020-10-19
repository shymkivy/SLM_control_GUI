function ops = f_SLM_BNS_close(ops)

    if ops.constructed_okay.value == 0
        % Always call Delete_SDK before exiting
        if ops.SDK_created == 1
            calllib('Blink_C_wrapper', 'Delete_SDK');
            disp('Deleted SDK')
            ops.SDK_created = 0;
        end
    end

    %destruct
    if libisloaded('Blink_C_wrapper')
        unloadlibrary('Blink_C_wrapper');
    end

    if libisloaded('ImageGen')
        unloadlibrary('ImageGen');
    end
    
end