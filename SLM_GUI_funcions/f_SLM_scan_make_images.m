function [holo_phase_all, out_params] = f_SLM_scan_make_images(app, pattern, add_blank)

if ~exist('add_blank', 'var')
    add_blank = false;
end

if ~strcmpi(pattern, 'none')
    idx_pat = strcmpi(pattern, [app.xyz_patterns.name_tag]);

    [m_idx, n_idx, xyz_affine_tf_mat, reg1] = f_SLM_get_reg_deets(app, app.xyz_patterns(idx_pat).SLM_region);
    
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
        
        xyzp = [gr_subtable(:,4:5), gr_subtable(:,3)*1e-6];
        xyzp2 = (xyz_affine_tf_mat*xyzp')';
        
        holo_complex = f_SLM_PhaseHologram_YS(xyzp2,...
                                        SLMm, SLMn,...
                                        gr_subtable(:,7),...
                                        gr_subtable(:,6),...
                                        app.ObjectiveRIEditField.Value,...
                                        app.WavelengthnmEditField.Value*1e-9);
        
        AO_wf = f_SLM_AO_get_correction(app, reg1, gr_subtable(:,3));                         
                   
        if ~isempty(AO_wf)
            holo_complex = holo_complex.*exp(1i*(AO_wf));
        end
        
        holo_phase_all(:,:,n_gr) = angle(holo_complex)+pi;
        %holo_phase_all(:,:,n_gr) = f_SLM_im_to_pointer(holo_phase);                
    end
    
    if add_blank
        holo_zero = zeros(SLMm, SLMn);

        AO_wf = f_SLM_AO_get_correction(app, reg1, 0); 

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