function mode_data = f_sg_get_zernike_mode_nm(modes)

zernike_cell_list = cell(numel(modes),1);

for mode = modes
    n_modes = (-mode:2:mode)';
    m_modes = ones(mode+1,1)*mode;
    zernike_cell_list{mode+1} = [m_modes,n_modes]; 
end

mode_data = cat(1, zernike_cell_list{:});

end