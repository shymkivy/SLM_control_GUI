function [holo_pointers, zernike_scan_sequence] = f_sg_AO_make_zernike_pointers(app, AO_phase, reg1)

%%
SLMm = sum(reg1.m_idx);
SLMn = sum(reg1.n_idx);
xlm = linspace(-SLMm/reg1.phase_diameter, SLMm/reg1.phase_diameter, SLMm);
xln = linspace(-SLMn/reg1.phase_diameter, SLMn/reg1.phase_diameter, SLMn);
[fX, fY] = meshgrid(xln, xlm);
[theta, rho] = cart2pol(fX, fY);

%% create pointers
zernike_table = app.ZernikeListTable.Data;

% generate all polynomials
num_modes = size(zernike_table,1);
all_modes = zeros(SLMm, SLMn, num_modes);
for n_mode = 1:num_modes
    Z_nm = f_sg_zernike_pol(rho, theta, zernike_table(n_mode,2), zernike_table(n_mode,3));
    if reg1.zero_outside_phase_diameter
        Z_nm(rho>1) = 0;
    end
    all_modes(:,:,n_mode) = Z_nm;
end

% generate scan sequence
all_patterns = cell(num_modes,1);
for n_mode = 1:num_modes
    if zernike_table(n_mode,7)
        weights1 = zernike_table(n_mode,4):zernike_table(n_mode,5):zernike_table(n_mode,6);
        all_patterns{n_mode} = [ones(numel(weights1),1)*zernike_table(n_mode,1), weights1']; 
    end
end

zernike_scan_sequence = cat(1,all_patterns{:});
zernike_scan_sequence = repmat(zernike_scan_sequence,app.ScanspermodeEditField.Value,1);
num_scans = size(zernike_scan_sequence,1);
if app.ShufflemodesCheckBox.Value
    zernike_scan_sequence = zernike_scan_sequence(randsample(num_scans,num_scans),:);
end

%% generate pointers
init_phase_corr_lut = app.SLM_phase_corr_lut;
init_phase_corr = app.SLM_phase_corr(reg1.m_idx, reg1.n_idx);

holo_pointers = cell(num_scans,1);
for n_plane = 1:num_scans
    n_mode = zernike_scan_sequence(n_plane,1);
    n_weight = zernike_scan_sequence(n_plane,2);
    
    holo_phase_corr_lut = init_phase_corr_lut;
    if n_mode == 999
        holo_phase_corr = ref_phase2;
    else
        holo_phase_corr = angle(exp(1i*(init_phase_corr + AO_phase + all_modes(:,:,n_mode)*n_weight)));
    end
    
    holo_phase_corr_lut(reg1.m_idx, reg1.n_idx) = f_sg_lut_apply_reg_corr(holo_phase_corr, reg1);
    holo_pointers{n_plane} = f_sg_initialize_pointer(app);
    holo_pointers{n_plane}.Value = reshape(holo_phase_corr_lut', [],1);
end

end