function all_modes_sum = f_sg_AO_compute_wf_core(modes_in, params)

phase_diameter = params.phase_diameter;
SLMm = params.SLMm;
SLMn = params.SLMn;

xlm = linspace(-SLMm/phase_diameter, SLMm/phase_diameter, SLMm);
xln = linspace(-SLMn/phase_diameter, SLMn/phase_diameter, SLMn);
[fX, fY] = meshgrid(xln, xlm);
[theta, rho] = cart2pol(fX, fY);

num_modes = size(modes_in,1);
max_mode = max(modes_in(:,1));

% compute n m
zernike_nm_list_cell = cell(max_mode+1,1);
for mode = 0:max_mode
    n_modes = (-mode:2:mode)';
    m_modes = ones(mode+1,1)*mode;
    zernike_nm_list_cell{mode+1} = [m_modes,n_modes]; 
end
zernike_nm_list = cat(1, zernike_nm_list_cell{:});

% generate all polynomials
all_modes = zeros(SLMm, SLMn, num_modes);
for n_mode_idx = 1:num_modes
    n_mode = modes_in(n_mode_idx,1);
    Z_nm = f_sg_zernike_pol(rho, theta, zernike_nm_list(n_mode,1), zernike_nm_list(n_mode,2));
    all_modes(:,:,n_mode_idx) = Z_nm*modes_in(n_mode_idx,2);
end

all_modes_sum = sum(all_modes,3);

%figure; imagesc(all_modes_sum)
end