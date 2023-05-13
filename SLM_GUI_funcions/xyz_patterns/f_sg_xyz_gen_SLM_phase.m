function [SLM_phase, holo_phase, SLM_phase_corr, holo_phase_corr, AO_phase] = f_sg_xyz_gen_SLM_phase(app, coord, reg1, apply_AO, method)

coord_corr = f_sg_coord_correct(reg1, coord);

if strcmpi(method, 'synthesis')
    
    comp_z1 = 0;
    if apply_AO
        if app.CompensatezCheckBox.Value
            if isfield(reg1.AO_wf, 'fit_defocus_comp')
                if strcmpi(class(reg1.AO_wf.fit_defocus_comp),'cfit')
                    comp_z1 = reg1.AO_wf.fit_defocus_comp(coord_corr.xyzp(3));
                    
                end
            end
        end
    end
    coord_corr.xyzp(3) = coord_corr.xyzp(3) + comp_z1;
    
    holo_phase = f_sg_PhaseHologram2(coord_corr, reg1);
    complex_exp = sum(exp(1i*(holo_phase)).*reshape(coord_corr.weight,[1 1 numel(coord_corr.weight)]),3);
    SLM_phase = angle(complex_exp);

    % add ao corrections
    if apply_AO
        % ao use uncorrected coords
        AO_phase = f_sg_AO_get_z_corrections(app, reg1, coord.xyzp(:,3));
        holo_phase_corr = holo_phase+AO_phase;
    else
        AO_phase = [];
        holo_phase_corr = holo_phase;
    end

    complex_exp_corr = sum(exp(1i*(holo_phase_corr)).*reshape(coord_corr.weight,[1 1 numel(coord_corr.weight)]),3);
    SLM_phase_corr = angle(complex_exp_corr);

elseif strcmpi(method, 'GS meadowlark')
    SLM_phase = f_sg_xyz_gen_holo_MGS(app, coord_corr, reg1);

    holo_phase = [];
    holo_phase_corr = [];
    SLM_phase_corr = SLM_phase;
    AO_phase = [];
elseif strcmpi(method, 'global GS')
    num_pts = size(coord_corr.xyzp,1);
    
    z_all = unique(coord_corr.xyzp(:,3));
    num_z = numel(z_all);
    siz = max(reg1.SLMm, reg1.SLMn);
    disc_size = 5;
    ph_d = reg1.phase_diameter;
    x_coord = round(((1:siz)-(siz/2)-1)/2/siz*ph_d,2);
    y_coord = round(((1:siz)-(siz/2)-1)/2/siz*ph_d,2);
    
    [X,Y] = meshgrid(x_coord,y_coord);
    
    xy_coord = [X(:), Y(:)];
    
    mask_disk = zeros(siz, siz);
    euc_dist_zero = sqrt(sum((xy_coord).^2,2));
    idx_disc = euc_dist_zero < disc_size;
    mask_disk(idx_disc) = 1;
    
    mask_all_pts = zeros(siz, siz, num_z);
    mask_all = zeros(siz, siz, num_z);
    for n_z = 1:num_z
        xyzp2 = coord_corr.xyzp(coord_corr.xyzp(:,3) == z_all(n_z),:);
        num_pts2 = size(xyzp2,1);
        for n_pt = 1:num_pts2
            temp_fr = mask_all(:,:,n_z);
            xyzp3 = xyzp2(n_pt,:);
            euc_dist = sqrt(sum((xyzp3(1:2) - xy_coord).^2,2));
            [~, idx_cent] = min(euc_dist);
            idx_disc = euc_dist < disc_size;
            temp_fr(idx_disc) = 1;
            mask_all(:,:,n_z) = temp_fr;
            
            temp_fr = mask_all_pts(:,:,n_z);
            temp_fr(idx_cent) = 1;
            mask_all_pts(:,:,n_z) = temp_fr;
        end
    end
    
    amp_fac = siz*siz;

    % stragegy 1 is to make points holograms, then multiply by disk holo
    complex_pts = fftshift(ifft2(ifftshift(mask_all_pts(:,:,1))));
    complex_disk = fftshift(ifft2(ifftshift(mask_disk)));
    complex1 = complex_pts.*complex_disk*amp_fac;
    
    % strategy 2 is make disks at start
    complex2 = fftshift(ifft2(ifftshift(mask_all)));
    
    % visualize the phases
    n_z = 1;
    figure; imagesc(abs(complex1(:,:,n_z)))
    figure; imagesc(abs(complex2(:,:,n_z)))
    figure; imagesc(angle(complex1(:,:,n_z)))
    figure; imagesc(angle(complex2(:,:,n_z)))
    
    % visualize the disks
    n_z = 1;
    figure(); imagesc(abs(fftshift(fft2(complex1(:,:,n_z)))))
    figure(); imagesc(abs(fftshift(fft2(complex2(:,:,n_z)))))
    
    figure(); imagesc(abs(fftshift(fft2(complex_disk))))
    figure(); imagesc(abs(fftshift(fft2(complex_pts(:,:,n_z)))))

end

end