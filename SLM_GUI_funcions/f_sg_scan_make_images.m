function [holo_phase_all, out_params] = f_sg_scan_make_images(app, pattern, add_blank)

if ~exist('add_blank', 'var')
    add_blank = false;
end

if ~strcmpi(pattern, 'none')
    idx_pat = strcmpi(pattern, [app.xyz_patterns.pat_name]);

    [m_idx, n_idx, reg1] = f_sg_get_reg_deets(app, app.xyz_patterns(idx_pat).SLM_region);
    
    SLMm = sum(m_idx);
    SLMn = sum(n_idx);
    
    pointer_idx = false(app.SLM_ops.height,app.SLM_ops.width);
    pointer_idx(m_idx,n_idx) = 1;
    pointer_idx = reshape(rot90(pointer_idx, 3), [],1);
    
    group_table = app.xyz_patterns(idx_pat).xyz_pts.Variables;
    groups = unique(group_table(:,2));
    
    %% precompute hologram patterns
    num_groups = numel(groups);
    
    holo_phase_all = zeros(SLMm, SLMn, num_groups);
    for n_gr = 1:num_groups
        curr_gr = groups(n_gr);
        gr_subtable = group_table(group_table(:,2) == curr_gr,:);
        
        xyzp = [gr_subtable(:,3:4), gr_subtable(:,5)*1e-6];
        xyzp2 = xyzp*reg1.xyz_affine_tf_mat;
        
        beam_diameter = reg1.beam_diameter;
        
        % generate 3d pattern, where each depth will get its own correction
        holo_complex_all = zeros(SLMm, SLMn);
        for n_pt = 1:size(xyzp2,1)
            holo_complex = f_sg_PhaseHologram_YS(xyzp2(n_pt,:),...
                                SLMm, SLMn,...
                                gr_subtable(n_pt,6),...
                                reg1.effective_NA,...
                                app.ObjectiveRIEditField.Value,...
                                reg1.wavelength*1e-9,...
                                beam_diameter);
            AO_wf = f_sg_AO_get_correction(app, reg1.reg_name, gr_subtable(n_pt,5));  
            if ~isempty(AO_wf)
                holo_complex = holo_complex.*exp(1i*(AO_wf(m_idx, n_idx)));
            end
            holo_complex_all = holo_complex_all + holo_complex;
        end
        
        if app.ZerooutsideunitcircCheckBox.Value
            holo_complex_all(reg1.holo_mask) = 1;
        end
                                    
        holo_phase_all(:,:,n_gr) = angle(holo_complex_all)+pi;
        %holo_phase_all(:,:,n_gr) = f_sg_im_to_pointer(holo_phase);                
    end
    
    if add_blank
        holo_zero = zeros(SLMm, SLMn);

        AO_wf = f_sg_AO_get_correction(app, reg1.reg_name, 0); 

        if ~isempty(AO_wf)
            holo_zero = holo_zero.*exp(1i*(AO_wf));
        end
        holo_zero = angle(holo_zero)+pi;

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