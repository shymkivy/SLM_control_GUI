function f_SLM_update(ops, image_pointer)

if ops.sdkObj.SDK_created
    if ops.sdkObj.WCF_add_on_update
        image_pointer = ops.sdkObj.add_WFC(image_pointer);
    end
    if ops.sdkObj.is_OD
        ops.sdkObj.write_image_OD(image_pointer);
    else
        ops.sdkObj.write_image(image_pointer);
    end
else
    disp('SLM is not active')
end

%im1 = double(reshape(image_pointer.Value, ops.sdkObj.width, ops.sdkObj.height))/256*2*pi;
%phase_sum = angle(exp(1i * (WFC_im1-pi)) .* exp(1i * (im1)))+pi;

%figure(); imagesc(im1')
%figure(); imagesc(WFC_im1')

end