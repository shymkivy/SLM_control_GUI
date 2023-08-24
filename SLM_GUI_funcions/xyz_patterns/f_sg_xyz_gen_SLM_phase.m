function [SLM_phase, holo_phase, SLM_phase_corr, holo_phase_corr, AO_phase] = f_sg_xyz_gen_SLM_phase(app, coord, reg1, apply_AO, method)

coord_corr = f_sg_coord_correct(reg1, coord);

holo_phase = [];
holo_phase_corr = [];
AO_phase = [];

coord_corr_zcomp = coord_corr;
comp_z1 = 0;
if apply_AO
    if app.CompensatezCheckBox.Value
        if isfield(reg1.AO_wf, 'fit_defocus_comp')
            if strcmpi(class(reg1.AO_wf.fit_defocus_comp),'cfit')
                comp_z1 = reg1.AO_wf.fit_defocus_comp(coord_corr_zcomp.xyzp(:,3));
            end
        end
    end
end
coord_corr_zcomp.xyzp(:,3) = coord_corr_zcomp.xyzp(:,3) + comp_z1;


if strcmpi(method, 'Superposition')
    
    holo_phase = f_sg_PhaseHologram2(coord_corr_zcomp, reg1);
    
    % add ao corrections
    if apply_AO
        % ao use uncorrected coords
        AO_phase = f_sg_AO_get_z_corrections(app, reg1, coord.xyzp(:,3));
        holo_phase_corr = holo_phase+AO_phase;
    else
        holo_phase_corr = holo_phase;
    end
    
    complex_exp = sum(exp(1i*(holo_phase)).*reshape(coord.W_est,[1 1 numel(coord.W_est)]),3);
    if apply_AO
        complex_exp_corr = sum(exp(1i*(holo_phase_corr)).*reshape(coord_corr.W_est,[1 1 numel(coord_corr.W_est)]),3);
    else
        complex_exp_corr = complex_exp;
    end

    if app.MakedisksCheckBox.Value
    
        FOV_size = reg1.FOV_size;

        x_coord = linspace(-FOV_size/2, FOV_size/2, reg1.SLMn);
        y_coord = linspace(-FOV_size/2, FOV_size/2, reg1.SLMm);
        [X,Y] = meshgrid(x_coord,y_coord);
        xy_coord = [X(:), Y(:)];
        
        mask_disk = zeros(reg1.SLMm, reg1.SLMn);
        euc_dist_zero = sqrt(sum((xy_coord).^2,2));
        idx_disc = euc_dist_zero < app.DiskradiusumEditField.Value;
        mask_disk(idx_disc) = 1;
        mask_disk = mask_disk/sum(mask_disk(:));

        %complex_disk = fftshift(ifft2(ifftshift(sqrt(mask_disk))));
        complex_disk = fftshift(ifft2(ifftshift(sqrt(mask_disk).*exp(1i*2*pi*randn(reg1.SLMm, reg1.SLMn)))));
        
        %im_amp = abs(fftshift(fft2(complex_disk)).^2);
        
        complex_exp = complex_exp.*complex_disk;
        complex_exp_corr = complex_exp_corr.*complex_disk;
    end
    
    SLM_phase = angle(complex_exp);
    if apply_AO
        SLM_phase_corr = angle(complex_exp_corr);
    else
        SLM_phase_corr = SLM_phase;
    end

elseif strcmpi(method, 'global_GS_Meadowlark')
    % no AO possible
    SLM_phase = f_sg_xyz_gen_holo_MGS(app, coord_corr, reg1);
    SLM_phase_corr = SLM_phase;
else
    
    % make input image from points
    mask_all = f_sg_xyz_make_pt_image(reg1, coord_corr, app.MakedisksCheckBox.Value, app.DiskradiusumEditField.Value);
    
    % make defocus 
    
    z_all = unique(coord_corr_zcomp.xyzp(:,3));
    num_z = numel(z_all);
    %defocus_phase = f_sg_DefocusPhase(reg_params);
    defocus_phase = f_sg_DefocusPhase2(reg1);
    defocus_cpx = complex(zeros(reg1.SLMm, reg1.SLMn, num_z));
    
    if apply_AO
        AO_phase = f_sg_AO_get_z_corrections(app, reg1, coord.xyzp(:,3));
    end

    for n_z=1:num_z
        defocus_phase_z = z_all(n_z)*1e-6.*defocus_phase;
        if apply_AO
            defocus_phase_z = defocus_phase_z+AO_phase(:,:,n_z);
        end
        % negative because Waller algorithm divides later
        defocus_cpx(:,:,n_z) = exp(-1i*defocus_phase_z);
    end

    %figure; imagesc(mask_all(:,:,1))
    %figure; imagesc(angle(defocus_cpx(:,:,1)))
    
    % Waller Lab params
    System.Nx = reg1.SLMm;
    System.Ny = reg1.SLMn;
    System.verbose=0;           % 1 or 0    Set this value to 1 to display activity, 0 otherwise
    System.useGPU = 0;          % 1 or 0    Use GPU to accelerate computation. Effective when Nx, Ny is large (e.g. 600*800).
    System.maxiter = 50;        % int       Number of iterations (for all methods explored)
    System.GSoffset = 0;%0.01;     % float>0   Regularization constant to allow low light background in 3D Gerchberg Saxton algorithms
    
    System.source = f_sg_get_beam_amp(reg1, app.UsegaussianbeamampCheckBox.Value);

    NovoCGHOptions.HighThreshold = 0.5;
    NovoCGHOptions.LowThreshold = 0.1;

    if strcmpi(method, 'global_GS')

        amp_fac = siz*siz;
    
        % stragegy 1 is to make points holograms, then multiply by disk holo
        complex_pts = fftshift(ifft2(ifftshift(mask_all(:,:,1))));
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

    elseif strcmpi(method, 'superposition_LW')
        Hologram = function_Superposition(System, defocus_cpx, mask_all);
        SLM_phase_corr = Hologram.phase;
    elseif strcmpi(method, 'global_GS_LW')
        Hologram = function_globalGS(System, defocus_cpx, mask_all);
        SLM_phase_corr = Hologram.phase;
    elseif strcmpi(method, 'NOVO_CGH_VarI_LW')
        Hologram = function_NOVO_CGH_VarI( System, defocus_cpx, mask_all, z_all, NovoCGHOptions);
        SLM_phase_corr = Hologram.phase;
    elseif strcmpi(method, 'NOVO_CGH_VarIEuclid_LW')
        Hologram = function_NOVO_CGH_VarIEuclid(System, defocus_cpx, mask_all, z_all);
        SLM_phase_corr = Hologram.phase;
    elseif strcmpi(method, 'NOVO_CGH_2PEuclid_LW')
        Hologram = function_NOVO_CGH_TPEuclid(System, defocus_cpx, mask_all.^2, z_all);
        SLM_phase_corr = Hologram.phase;
    end
    SLM_phase = SLM_phase_corr;
end

end