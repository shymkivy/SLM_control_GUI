function mask_out = f_make_region_mask(siz_m, siz_n,reg_m,reg_n,reg_idx)

mask_out = zeros(siz_m, siz_n);

m_bounds = round(linspace(0, siz_m,reg_m+1));
n_bounds = round(linspace(0, siz_n,reg_n+1));

[row,col] = ind2sub([reg_m, reg_n],reg_idx);

mask_out((m_bounds(row)+1):m_bounds(row+1), (n_bounds(col)+1):n_bounds(col+1)) = 1;

end