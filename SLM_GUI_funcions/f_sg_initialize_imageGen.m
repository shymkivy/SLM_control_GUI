function f_sg_initialize_imageGen(app, reg1)

if ~libisloaded('ImageGen') 
    loadlibrary([app.SLM_ops.imageGen_dir, '\ImageGen.dll'], [app.SLM_ops.imageGen_dir, '\ImageGen.h']);
    app.SLM_ops.ImageGen.loaded = 1;
    app.SLM_ops.ImageGen.GS_init = 0;
end

num_iter = app.GSnumiterationsEditField.Value;

if app.SLM_ops.ImageGen.GS_init
    if or(or(app.SLM_ops.ImageGen.GS_num_iter ~= num_iter, app.SLM_ops.ImageGen.GS_SLMm ~= reg1.SLMm), app.SLM_ops.ImageGen.GS_SLMn ~= reg1.SLMn)
        calllib('ImageGen', 'Destruct_HologramGenerator')
        app.SLM_ops.ImageGen.GS_init = 0;
    end
end

if ~app.SLM_ops.ImageGen.GS_init
    im_funct = libfunctions('ImageGen');
    if sum(strcmpi(im_funct, 'CalculateAffinePolynomials'))
        app.SLM_ops.ImageGen.new_ver = 1;
        app.ImageGenverEditField.Value = '4, new';

        bit_depth = 8;
        RGB = 0;

        init_out = calllib('ImageGen', 'Initialize_HologramGenerator',...
                reg1.SLMn, reg1.SLMm, bit_depth,...
                num_iter, RGB);
    else
        app.SLM_ops.ImageGen.new_ver = 0;
        app.ImageGenverEditField.Value = '3, old';

        init_out = calllib('ImageGen', 'Initalize_HologramGenerator',...
                reg1.SLMn, reg1.SLMm,...
                num_iter);
    end
    app.SLM_ops.ImageGen.GS_init = init_out;
    if ~init_out; fprintf('GS init failed\n'); end   
end

app.SLM_ops.ImageGen.GS_num_iter = num_iter;
app.SLM_ops.ImageGen.GS_SLMm = reg1.SLMm;
app.SLM_ops.ImageGen.GS_SLMn = reg1.SLMn;

end