function all_modes = f_sg_gen_zernike_modes(reg1, zernike_table)

num_modes = size(zernike_table,1);

xlm = linspace(-reg1.SLMm/reg1.phase_diameter, reg1.SLMm/reg1.phase_diameter, reg1.SLMm);
xln = linspace(-reg1.SLMn/reg1.phase_diameter, reg1.SLMn/reg1.phase_diameter, reg1.SLMn);
[fX, fY] = meshgrid(xln, xlm);
[theta, rho] = cart2pol(fX, fY);

all_modes = zeros(reg1.SLMm, reg1.SLMn, num_modes);
for n_mode = 1:num_modes
    Z_nm = f_sg_zernike_pol(rho, theta, zernike_table(n_mode,2), zernike_table(n_mode,3));
    if reg1.zero_outside_phase_diameter
        Z_nm(rho>1) = 0;
    end
    all_modes(:,:,n_mode) = Z_nm;
end

end