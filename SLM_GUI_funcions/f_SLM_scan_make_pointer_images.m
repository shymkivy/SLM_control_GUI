function [holo_patterns, roi_idx] = f_SLM_scan_make_pointer_images(app, pattern, add_blank)

if ~exist('add_blank', 'var')
    add_blank = false;
end
    
if ~strcmpi(pattern, 'none')
    idx_pat = strcmpi(pattern, [app.xyz_patterns.name_tag]);
    idx_roi = strcmpi(app.xyz_patterns(idx_pat).SLM_roi, [app.SLM_roi_list.name_tag]);

    roi1 = app.SLM_roi_list(idx_roi);
    m = roi1.height_range;
    n = roi1.width_range;
    SLMm = m(2) - m(1) + 1;
    SLMn = n(2) - n(1) + 1;
    
    roi_idx = false(app.SLM_ops.height,app.SLM_ops.width);
    roi_idx(m(1):m(2),n(1):n(2)) = 1;
    roi_idx = reshape(rot90(roi_idx, 3), [],1);
    
    group_table = app.xyz_patterns(idx_pat).xyz_pts.Variables;
    groups = unique(group_table(:,1));

    %% precompute hologram patterns
    num_groups = numel(groups);
    
    holo_patterns = zeros(SLMm*SLMn, num_groups, 'uint8');
    for n_gr = 1:num_groups
        curr_gr = groups(n_gr);
        gr_subtable = group_table(group_table(:,1) == curr_gr,:);

        holo_image = f_SLM_PhaseHologram_YS([gr_subtable(:,3:4), gr_subtable(:,2)*10e-6],...
                                        SLMm, SLMn,...
                                        gr_subtable(:,6),...
                                        gr_subtable(:,5),...
                                        app.ObjectiveRIEditField.Value,...
                                        app.WavelengthnmEditField.Value*10e-9);

        holo_image = f_SLM_AO_add_correction(app,holo_image);
        holo_patterns(:,n_gr) = f_SLM_im_to_pointer(holo_image);                
    end
end

if add_blank
    holo_zero = zeros(SLMm, SLMn, 'uint8');
    holo_zero = f_SLM_AO_add_correction(app,holo_zero);
    holo_zero = f_SLM_im_to_pointer(holo_zero);
    holo_patterns = [holo_zero,holo_patterns];
end

end