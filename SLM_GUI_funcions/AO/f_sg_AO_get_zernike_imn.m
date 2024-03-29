function zernike_imn3 = f_sg_AO_get_zernike_imn(modes_use)

modes_all = 0:max(modes_use);
zernike_mn = f_sg_get_zernike_mode_nm(modes_all);
num_modes_all = size(zernike_mn,1);
zernike_imn = [(1:num_modes_all)', zernike_mn];

zernike_use_modes = true(num_modes_all,1);
zernike_use_modes(zernike_mn(:,1) == 0) = 0;
zernike_use_modes(zernike_mn(:,1) == 1) = 0;
zernike_use_modes(and(zernike_mn(:,1) == 2, zernike_mn(:,2) == 0)) = 0;

zernike_imn2 = zernike_imn(zernike_use_modes,:);

zernike_imn3 = zernike_imn2(logical(sum(zernike_imn2(:,2) == modes_use,2)),:);

end