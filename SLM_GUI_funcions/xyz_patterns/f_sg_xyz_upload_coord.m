function f_sg_xyz_upload_coord(app, coord)

%% generate image
if ~isempty(coord)
    reg1 = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);
    
    app.GUI_buffer.current_AO_phase = [];
    
    %% update slm im
    
    if strcmpi(app.GenXYZpatmethodDropDown.Value, 'synthesis')
        holo_phase = f_sg_xyz_gen_holo(coord, reg1);
   
        complex_exp = sum(exp(1i*(holo_phase)).*reshape(coord.weight,[1 1 numel(coord.weight)]),3);
        
        SLM_phase = angle(complex_exp);

        % add ao corrections
        if app.ApplyAOcorrectionButton.Value
            AO_phase = f_sg_AO_get_z_corrections(app, reg1, coord.xyzp(:,3));
            app.GUI_buffer.current_AO_phase = AO_phase;

            holo_phase_corr = holo_phase+AO_phase;
        else
            holo_phase_corr = holo_phase;
        end

        complex_exp_corr = sum(exp(1i*(holo_phase_corr)).*reshape(coord.weight,[1 1 numel(coord.weight)]),3);
        SLM_phase_corr = angle(complex_exp_corr);
        
    elseif strcmpi(app.GenXYZpatmethodDropDown.Value, 'GS meadowlark')
        
        coord_corr = coord;
        coord_corr.xyzp = (coord.xyzp+reg1.xyz_offset)*reg1.xyz_affine_tf_mat;
        
        if ~libisloaded('ImageGen') 
            loadlibrary([app.SLM_ops.imageGen_dir, '\ImageGen.dll'], [app.SLM_ops.imageGen_dir, '\ImageGen.h']);
        end
        
        phase_ptr = libpointer('uint8Ptr', zeros(reg1.SLMn*reg1.SLMm,1));
        WFC_ptr = libpointer('uint8Ptr', zeros(reg1.SLMn*reg1.SLMm,1));
        %bit_depth = app.SLM_ops.bit_depth;
        bit_depth = 8;
        n_iter = app.GSnumiterationsEditField.Value;
        GS_z_fac = app.GSzfactorEditField.Value;
        RGB = 0;
        
        % IMAGE_GEN_API int Initialize_HologramGenerator(int width, int height, int depth, int iterations, int RGB)
        % IMAGE_GEN_API int Generate_Hologram(unsigned char *Array, unsigned char* WFC, float *x_spots, float *y_spots, float *z_spots, float *I_spots, int N_spots, int ApplyAffine);
        % IMAGE_GEN_API void Destruct_HologramGenerator();
        
        calllib('ImageGen', 'Initialize_HologramGenerator',...
            reg1.SLMn, reg1.SLMm, bit_depth,...
            n_iter, RGB);
        
        calllib('ImageGen', 'Generate_Hologram',...
                    phase_ptr, WFC_ptr,...
                    coord_corr.xyzp(:,1)*2,...
                    -coord_corr.xyzp(:,2)*2,...
                    coord_corr.xyzp(:,3)*GS_z_fac,....
                    coord_corr.weight,...
                    numel(coord_corr.weight),...
                    0);
        
        calllib('ImageGen', 'Destruct_HologramGenerator')
        
        holo_phase = [];
        holo_phase_corr = [];
        SLM_phase = f_sg_poiner_to_im(phase_ptr, reg1.SLMm, reg1.SLMn)-pi;
        SLM_phase_corr = SLM_phase;
    end
    
    %% apply mask
    if reg1.zero_outside_phase_diameter
        SLM_phase(~reg1.holo_mask) = 0;
        SLM_phase_corr(~reg1.holo_mask) = 0;
    end
    
    %% apply lut correction
    SLM_phase_corr_lut = f_sg_lut_apply_reg_corr(SLM_phase_corr, reg1);
    
    %% save
    
    app.current_SLM_coord = coord;
    app.GUI_buffer.current_SLM_coord = coord;
    app.GUI_buffer.current_region = reg1;
    app.GUI_buffer.current_holo_phase = holo_phase;
    
    app.GUI_buffer.current_holo_phase_corr = holo_phase_corr;
    
    app.GUI_buffer.current_SLM_phase = SLM_phase;
    app.GUI_buffer.current_SLM_phase_corr = SLM_phase_corr;
    app.GUI_buffer.current_SLM_phase_corr_lut = SLM_phase_corr_lut;
    
    app.SLM_phase(reg1.m_idx, reg1.n_idx) = SLM_phase;
    app.SLM_phase_corr(reg1.m_idx, reg1.n_idx) = SLM_phase_corr;
    app.SLM_phase_corr_lut(reg1.m_idx, reg1.n_idx) = SLM_phase_corr_lut;
    
    %% upload local region to SLM
    f_sg_upload_image_to_SLM(app);
end

end