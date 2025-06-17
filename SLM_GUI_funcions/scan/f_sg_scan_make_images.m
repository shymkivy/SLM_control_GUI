function [holo_phase_all, out_params, group_table] = f_sg_scan_make_images(app, pattern, add_blank)

if ~exist('add_blank', 'var')
    add_blank = false;
end

if ~strcmpi(pattern, 'none')
    idx_pat = strcmpi(pattern, {app.xyz_patterns.pat_name});
    reg1 = f_sg_get_reg_deets(app, app.xyz_patterns(idx_pat).SLM_region);
    
    pointer_idx = false(app.SLM_ops.sdkObj.height, app.SLM_ops.sdkObj.width);
    pointer_idx(reg1.m_idx, reg1.n_idx) = 1;
    pointer_idx = reshape(pointer_idx', [],1);
    
    group_table = app.xyz_patterns(idx_pat).xyz_pts;
    groups = unique(group_table.Pattern);

    %% precompute hologram patterns
    num_groups = numel(groups);
    
    holo_phase_all = zeros(reg1.SLMm, reg1.SLMn, num_groups, 'uint8');

    
    for n_gr = 1:num_groups
        curr_gr = groups(n_gr);
        gr_subtable = group_table(group_table.Pattern == curr_gr,:);
        
        coord.idx = gr_subtable.Idx;
        coord.xyzp = [gr_subtable.X, gr_subtable.Y, gr_subtable.Z];
        coord.I_targ = gr_subtable.I_targ;
        
        if app.I_targI22PCheckBox.Value
            coord.I_targ1P = sqrt(coord.I_targ);
        else
            coord.I_targ1P = coord.I_targ;
        end
        coord.W_est = sqrt(coord.I_targ1P);

        [~, ~, SLM_phase_corr, ~, ~] = f_sg_xyz_gen_SLM_phase(app, coord, reg1, app.ApplyAOcorrectionButton.Value, app.XYZpatalgotithmDropDown.Value);
        
        %% apply ZO suppression
        if app.ApplyZOsuppressionButton.Value
            SLM_phase_corr = f_sg_apply_ZO_corr(SLM_phase_corr, reg1);
            %SLM_phase = f_sg_apply_ZO_corr(SLM_phase, reg1);
        end
        
        %% apply mask
        if reg1.zero_outside_phase_diameter
            %SLM_phase(~reg1.holo_mask) = 0;
            SLM_phase_corr(~reg1.holo_mask) = 0;
        end
    
        %% apply lut correction
        SLM_phase_corr_lut = f_sg_lut_apply_reg_corr(SLM_phase_corr, reg1);
        
        %% old code
        %coord_corr = f_sg_coord_correct(reg1, coord);         
        %holo_phase = f_sg_PhaseHologram2(coord_corr, reg1);

        %holo_phase = f_sg_xyz_gen_holo(coord, reg1);
        %AO_phase = f_sg_AO_get_z_corrections(app, reg1, coord.xyzp(:,3));
        
        % holo_phase_corr = holo_phase+AO_phase;
        % SLM_phase_corr = angle(sum(exp(1i*(holo_phase_corr)).*reshape(coord.W_est,[1 1 numel(coord.W_est)]),3));
        % SLM_phase_corr_lut = f_sg_lut_apply_reg_corr(SLM_phase_corr, reg1);
        % 
        holo_phase_all(:,:,n_gr) = SLM_phase_corr_lut;
        %holo_phase_all(:,:,n_gr) = f_sg_im_to_pointer(holo_phase);                
    end
    
    if add_blank
        %holo_zero = zeros(reg1.SLMm, reg1.SLMn, 'uint8');

        coord_blank.xyzp = [reg1.beam_dump_xy(1), reg1.beam_dump_xy(2), 0];
        coord_blank.W_est = 1;
        [~, ~, SLM_phase_zero_corr, ~, ~] = f_sg_xyz_gen_SLM_phase(app, coord_blank, reg1, app.ApplyAOcorrectionButton.Value, app.XYZpatalgotithmDropDown.Value);
        if app.ApplyZOsuppressionButton.Value
            SLM_phase_zero_corr = f_sg_apply_ZO_corr(SLM_phase_zero_corr, reg1);
            %SLM_phase = f_sg_apply_ZO_corr(SLM_phase, reg1);
        end
        
        %% apply mask
        if reg1.zero_outside_phase_diameter
            %SLM_phase(~reg1.holo_mask) = 0;
            SLM_phase_zero_corr(~reg1.holo_mask) = 0;
        end
        
        SLM_phase_zero_corr_lut = f_sg_lut_apply_reg_corr(SLM_phase_zero_corr, reg1);

        holo_phase_all = cat(3,SLM_phase_zero_corr_lut,holo_phase_all);
    end
else
    holo_phase_all = [];
    %reg_idx = [];
end

out_params.m_idx = reg1.m_idx;
out_params.n_idx = reg1.n_idx;
out_params.pointer_idx = pointer_idx;

end