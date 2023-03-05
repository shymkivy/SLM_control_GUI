function f_sg_destruct_imageGen(app)

if app.SLM_ops.ImageGen.GS_init
    calllib('ImageGen', 'Destruct_HologramGenerator')
    app.SLM_ops.ImageGen.GS_init = 0;
end

if libisloaded('ImageGen')
    unloadlibrary('ImageGen');
    app.SLM_ops.ImageGen.loaded = 0;
end

end