function Znm_data = f_sg_get_zernike_mode_nm(Zn_list)

zernike_cell_list = cell(numel(Zn_list),1);

for Zn = Zn_list
    m_modes = (-Zn:2:Zn)';
    n_modes = ones(Zn+1,1)*Zn;
    zernike_cell_list{Zn+1} = [n_modes,m_modes]; 
end

Znm_data = cat(1, zernike_cell_list{:});

end