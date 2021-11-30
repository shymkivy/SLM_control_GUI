function [holo_phase_all, out_params] = f_sg_scan_make_images(app, pattern, add_blank)

if ~exist('add_blank', 'var')
    add_blank = false;
end

if ~strcmpi(pattern, 'none')
    idx_pat = strcmpi(pattern, {app.xyz_patterns.pat_name});

    [m_idx, n_idx, reg1] = f_sg_get_reg_deets(app, app.xyz_patterns(idx_pat).SLM_region);
    
    SLMm = sum(m_idx);
    SLMn = sum(n_idx);
    
    pointer_idx = false(app.SLM_ops.height,app.SLM_ops.width);
    pointer_idx(m_idx,n_idx) = 1;
    pointer_idx = reshape(pointer_idx', [],1);
    
    group_table = app.xyz_patterns(idx_pat).xyz_pts.Variables;
    groups = unique(group_table(:,2));
    
    %% precompute hologram patterns
    num_groups = numel(groups);
    
    holo_phase_all = zeros(SLMm, SLMn, num_groups, 'uint8');
    for n_gr = 1:num_groups
        curr_gr = groups(n_gr);
        gr_subtable = group_table(group_table(:,2) == curr_gr,:);
        
        coord.idx = gr_subtable(:,1);
        coord.xyzp = gr_subtable(:,3:5);
        coord.weight = gr_subtable(:,6);
        coord.NA = reg1.effective_NA;
        
        holo_phase = f_sg_xyz_gen_holo(app, coord, reg1);
        
        AO_phase = f_sg_AO_get_z_corrections(app, reg1, coord.xyzp(:,3));
        
        holo_phase_corr = holo_phase+AO_phase;
        
        SLM_phase_corr = angle(sum(exp(1i*(holo_phase_corr)).*reshape(coord.weight,[1 1 numel(coord.weight)]),3));
        
        SLM_phase_corr_lut = f_sg_lut_apply_reg_corr(SLM_phase_corr, reg1);
        
        holo_phase_all(:,:,n_gr) = SLM_phase_corr_lut;
        %holo_phase_all(:,:,n_gr) = f_sg_im_to_pointer(holo_phase);                
    end
    
    if add_blank
        holo_zero = zeros(SLMm, SLMn, 'uint8');
        holo_phase_all = cat(3,holo_zero,holo_phase_all);
    end
else
    holo_phase_all = [];
    %reg_idx = [];
end

out_params.m_idx = m_idx;
out_params.n_idx = n_idx;
out_params.pointer_idx = pointer_idx;

end