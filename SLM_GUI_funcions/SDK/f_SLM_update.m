function f_SLM_update(ops, image_pointer)

if ops.sdkObj.SDK_created
    if ops.sdkObj.is_OD
        ops.sdkObj.write_image_OD(image_pointer);
    else
        ops.sdkObj.write_image(image_pointer);
    end
else
    disp('SLM is not active')
end


end