function [holo_phase, reg_idx] = f_SLM_scan_make_pointer_images(app, pattern, add_blank)

if ~exist('add_blank', 'var')
    add_blank = false;
end
    
if ~strcmpi(pattern, 'none')
    idx_pat = strcmpi(pattern, [app.xyz_patterns.name_tag]);

    [m_idx, n_idx, xyz_affine_tf_mat, reg1] = f_SLM_get_reg_deets(app, app.xyz_patterns(idx_pat).SLM_region);
    
    SLMm = sum(m_idx);
    SLMn = sum(n_idx);
    
    reg_idx = false(app.SLM_ops.height,app.SLM_ops.width);
    reg_idx(m_idx,n_idx) = 1;
    reg_idx = reshape(rot90(reg_idx, 3), [],1);
    
    group_table = app.xyz_patterns(idx_pat).xyz_pts.Variables;
    groups = unique(group_table(:,2));

    %% precompute hologram patterns
    num_groups = numel(groups);
    
    holo_phase = zeros(SLMm*SLMn, num_groups, 'uint8');
    for n_gr = 1:num_groups
        curr_gr = groups(n_gr);
        gr_subtable = group_table(group_table(:,2) == curr_gr,:);
        
        xyzp = [gr_subtable(:,4:5), gr_subtable(:,3)*10e-6];
        xyzp2 = (xyz_affine_tf_mat*xyzp')';
        
        holo_image = f_SLM_PhaseHologram_YS(xyzp2,...
                                        SLMm, SLMn,...
                                        gr_subtable(:,7),...
                                        gr_subtable(:,6),...
                                        app.ObjectiveRIEditField.Value,...
                                        app.WavelengthnmEditField.Value*10e-9);
        
        if isstruct(reg1.AO_wf)
            Z = mean(gr_subtable(:,3));
            [dist1, idx] = min(abs(Z - [reg1.AO_wf.Z]));
            if dist1 <= 20
                AO_wf2 = reg1.AO_wf(idx).wf_out;
            else
                AO_wf2 = zeros(size(reg1.AO_wf(idx).wf_out));
            end
        else
            AO_wf2 = reg1.AO_wf;
        end                
        
        
        if ~isempty(AO_wf2)
            holo_image = holo_image.*exp(1i*(AO_wf2(m_idx,n_idx)));
        end
        
        holo_phase1 = angle(holo_image)+pi;
        holo_phase(:,n_gr) = f_SLM_im_to_pointer(holo_phase1);                
    end
    
    if add_blank
        holo_zero = zeros(SLMm, SLMn, 'uint8');
        holo_zero = f_SLM_AO_add_correction(app,holo_zero, reg1.AO_wf);
        holo_zero = f_SLM_im_to_pointer(holo_zero);
        holo_phase = [holo_zero,holo_phase];
    end

else
    holo_phase = [];
    reg_idx = [];
end


end