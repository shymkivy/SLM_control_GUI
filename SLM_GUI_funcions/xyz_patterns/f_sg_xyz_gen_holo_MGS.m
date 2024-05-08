function SLM_phase = f_sg_xyz_gen_holo_MGS(app, coord, reg1)

f_sg_imageGen_initGS_wrap(app, reg1);

phase_ptr = libpointer('uint8Ptr', zeros(reg1.SLMn*reg1.SLMm,1));

GS_z_fac = app.GSzfactorEditField.Value;

if app.SLM_ops.ImageGen.new_ver
    
    WFC_ptr = libpointer('uint8Ptr', zeros(reg1.SLMn*reg1.SLMm,1));
    
    % IMAGE_GEN_API int Initialize_HologramGenerator(int width, int height, int depth, int iterations, int RGB)
    % IMAGE_GEN_API int Generate_Hologram(unsigned char *Array, unsigned char* WFC, float *x_spots, float *y_spots, float *z_spots, float *I_spots, int N_spots, int ApplyAffine);
    % IMAGE_GEN_API void Destruct_HologramGenerator();

    gen_out = calllib('ImageGen', 'Generate_Hologram',...
                phase_ptr, WFC_ptr,...
                coord.xyzp(:,1)*2,...
                -coord.xyzp(:,2)*2,...
                coord.xyzp(:,3)*GS_z_fac,....
                coord.I_targ1P,...
                numel(coord.W_est),...
                0);
else
    
    % IMAGE_GEN_API bool Initalize_HologramGenerator(int width, int height, int iterations);
    % IMAGE_GEN_API bool Generate_Hologram(unsigned char *Array, float *x_spots, float *y_spots, float *z_spots, float *I_spots, int N_spots);
    % IMAGE_GEN_API void Destruct_HologramGenerator();

    gen_out = calllib('ImageGen', 'Generate_Hologram',...
                phase_ptr,...
                coord.xyzp(:,1)*2,...
                -coord.xyzp(:,2)*2,...
                coord.xyzp(:,3)*GS_z_fac,....
                coord.I_targ1P,...
                numel(coord.W_est));
            
end
   
if ~gen_out; fprintf('GS gen failed\n'); end

SLM_phase = f_sg_poiner_to_im(phase_ptr, reg1.SLMm, reg1.SLMn)-pi;

end