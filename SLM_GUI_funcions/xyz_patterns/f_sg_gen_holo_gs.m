function holo_out = f_sg_gen_holo_gs(app, coord, reg1)

SLMm = sum(reg1.m_idx);
SLMn = sum(reg1.n_idx);

iter = 100;

pointer1 = libpointer('uint8Ptr', zeros(app.SLM_ops.width*app.SLM_ops.height,1));

x = calllib('ImageGen', 'Initalize_HologramGenerator', SLMn, SLMm, iter);


coord

x2 = calllib('ImageGen', 'Generate_Hologram', pointer1, [0], [0], [10], [1], 1);

calllib('ImageGen', 'Destruct_HologramGenerator');


im1 = f_sg_poiner_to_im(pointer1, app.SLM_ops.height, app.SLM_ops.width);

figure; imagesc(im1)

end