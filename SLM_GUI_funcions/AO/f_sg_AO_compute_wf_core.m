function all_modes = f_sg_AO_compute_wf_core(modes_in, params)

phase_diameter = params.phase_diameter;
SLMm = params.SLMm;
SLMn = params.SLMn;

xlm = linspace(-SLMm/phase_diameter, SLMm/phase_diameter, SLMm);
xln = linspace(-SLMn/phase_diameter, SLMn/phase_diameter, SLMn);
[fX, fY] = meshgrid(xln, xlm);
[theta, rho] = cart2pol(fX, fY);

[num_modes, num_fit] = size(modes_in);
max_mode = max(modes_in(:,1));

maxZn = ceil((-1 + sqrt(1 + 4*max_mode*2))/2)-1;

% compute n m
zernike_nm_list_cell = cell(maxZn+1,1);
for Zn = 0:maxZn
    n_modes = (-Zn:2:Zn)';
    m_modes = ones(Zn+1,1)*Zn;
    zernike_nm_list_cell{Zn+1} = [m_modes,n_modes]; 
end
zernike_nm_list = cat(1, zernike_nm_list_cell{:});

% generate all polynomials
all_modes = zeros(SLMm, SLMn, num_modes);
for n_mode_idx = 1:num_modes
    n_mode = modes_in(n_mode_idx,1);
    Z_nm = f_sg_zernike_pol(rho, theta, zernike_nm_list(n_mode,1), zernike_nm_list(n_mode,2));
    all_modes(:,:,n_mode_idx) = Z_nm;
end

% generate all polynomials
% all_modes = zeros(SLMm, SLMn, num_modes);
% for n_mode_idx = 1:num_modes
%     n_mode = modes_in(n_mode_idx,1);
%     Z_nm = f_sg_zernike_pol(rho, theta, zernike_nm_list(n_mode,1), zernike_nm_list(n_mode,2));
%     if num_fit == 2
%         all_modes(:,:,1,n_mode_idx) = Z_nm*modes_in(n_mode_idx,2);
%     elseif num_fit == 3
%         all_modes(:,:,1,n_mode_idx) = Z_nm*modes_in(n_mode_idx,2);
%         all_modes(:,:,2,n_mode_idx) = Z_nm*modes_in(n_mode_idx,3);
%     elseif num_fit == 4
%         all_modes(:,:,1,n_mode_idx) = Z_nm*modes_in(n_mode_idx,2);
%         all_modes(:,:,2,n_mode_idx) = Z_nm*modes_in(n_mode_idx,3);
%         all_modes(:,:,3,n_mode_idx) = Z_nm*modes_in(n_mode_idx,3);
%     end
% end

%all_modes_fit_sum = sum(all_modes,4);
%figure; imagesc(all_modes_sum)
end