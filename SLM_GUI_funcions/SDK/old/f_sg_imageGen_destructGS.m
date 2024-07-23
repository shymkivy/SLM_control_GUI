function ops = f_sg_imageGen_destructGS(ops)

if isfield(ops, 'ImageGen')
    if ops.ImageGen.GS_init
        calllib('ImageGen', 'Destruct_HologramGenerator')
        ops.ImageGen.GS_init = 0;
    end
end

end