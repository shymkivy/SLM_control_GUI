function ops = f_sg_destruct_imageGen(ops)

if isfield(ops, 'ImageGen')
    if ops.ImageGen.GS_init
        calllib('ImageGen', 'Destruct_HologramGenerator')
        ops.ImageGen.GS_init = 0;
    end

    if libisloaded('ImageGen')
        unloadlibrary('ImageGen');
        ops.ImageGen.loaded = 0;
    end
end

end