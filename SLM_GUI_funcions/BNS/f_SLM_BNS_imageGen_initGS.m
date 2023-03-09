function ops = f_SLM_BNS_imageGen_initGS(ops, reg1, num_iter)

if ~libisloaded('ImageGen') 
    loadlibrary([ops.imageGen_dir, '\ImageGen.dll'], [ops.imageGen_dir, '\ImageGen.h']);
end

if ~isfield(ops, 'ImageGen')
    ops.ImageGen.GS_init = 0;
elseif ~isfield(ops.ImageGen, 'GS_init')
    ops.ImageGen.GS_init = 0;
end

if ops.ImageGen.GS_init
    if or(or(ops.ImageGen.GS_num_iter ~= num_iter, ops.ImageGen.GS_SLMm ~= reg1.SLMm), ops.ImageGen.GS_SLMn ~= reg1.SLMn)
        calllib('ImageGen', 'Destruct_HologramGenerator')
        ops.ImageGen.GS_init = 0;
    end
end

if ~ops.ImageGen.GS_init
    im_funct = libfunctions('ImageGen');
    if sum(strcmpi(im_funct, 'CalculateAffinePolynomials'))
        ops.ImageGen.new_ver = 1;
        ops.ImageGen.bit_depth = 8;
        ops.ImageGen.RGB = 0;
        
        init_out = calllib('ImageGen', 'Initialize_HologramGenerator',...
                reg1.SLMn, reg1.SLMm, ops.ImageGen.bit_depth,...
                num_iter, ops.ImageGen.RGB);
    else
        ops.ImageGen.new_ver = 0;
        init_out = calllib('ImageGen', 'Initalize_HologramGenerator',...
                reg1.SLMn, reg1.SLMm,...
                num_iter);
    end
    ops.ImageGen.GS_init = init_out;
    if ~init_out; fprintf('GS init failed\n'); end   
end

ops.ImageGen.GS_num_iter = num_iter;
ops.ImageGen.GS_SLMm = reg1.SLMm;
ops.ImageGen.GS_SLMn = reg1.SLMn;


end