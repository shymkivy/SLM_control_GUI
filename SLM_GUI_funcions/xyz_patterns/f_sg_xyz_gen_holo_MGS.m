function SLM_phase = f_sg_xyz_gen_holo_MGS(app, coord, reg1)

f_sg_initialize_imageGen(app);

phase_ptr = libpointer('uint8Ptr', zeros(reg1.SLMn*reg1.SLMm,1));

n_iter = app.GSnumiterationsEditField.Value;
GS_z_fac = app.GSzfactorEditField.Value;

if app.SLM_ops.imageGen_newver
    
    WFC_ptr = libpointer('uint8Ptr', zeros(reg1.SLMn*reg1.SLMm,1));
    bit_depth = 8;
    RGB = 0;

    % IMAGE_GEN_API int Initialize_HologramGenerator(int width, int height, int depth, int iterations, int RGB)
    % IMAGE_GEN_API int Generate_Hologram(unsigned char *Array, unsigned char* WFC, float *x_spots, float *y_spots, float *z_spots, float *I_spots, int N_spots, int ApplyAffine);
    % IMAGE_GEN_API void Destruct_HologramGenerator();

    init_out = calllib('ImageGen', 'Initialize_HologramGenerator',...
                reg1.SLMn, reg1.SLMm, bit_depth,...
                n_iter, RGB);

    gen_out = calllib('ImageGen', 'Generate_Hologram',...
                phase_ptr, WFC_ptr,...
                coord.xyzp(:,1)*2,...
                -coord.xyzp(:,2)*2,...
                coord.xyzp(:,3)*GS_z_fac,....
                coord.weight_set,...
                numel(coord.weight_set),...
                0);
else
    
    % IMAGE_GEN_API bool Initalize_HologramGenerator(int width, int height, int iterations);
    % IMAGE_GEN_API bool Generate_Hologram(unsigned char *Array, float *x_spots, float *y_spots, float *z_spots, float *I_spots, int N_spots);
    % IMAGE_GEN_API void Destruct_HologramGenerator();
    
    init_out = calllib('ImageGen', 'Initalize_HologramGenerator',...
                reg1.SLMn, reg1.SLMm,...
                n_iter);

    gen_out = calllib('ImageGen', 'Generate_Hologram',...
                phase_ptr,...
                coord.xyzp(:,1)*2,...
                -coord.xyzp(:,2)*2,...
                coord.xyzp(:,3)*GS_z_fac,....
                coord.weight_set,...
                numel(coord.weight_set));
            
end

calllib('ImageGen', 'Destruct_HologramGenerator')

if ~init_out; fprintf('GS init failed\n'); end       
if ~gen_out; fprintf('GS gen failed\n'); end

SLM_phase = f_sg_poiner_to_im(phase_ptr, reg1.SLMm, reg1.SLMn)-pi;

end