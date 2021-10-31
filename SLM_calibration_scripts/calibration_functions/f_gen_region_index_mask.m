function pixel_region_idx = f_gen_region_index_mask(SLMm, SLMn, region_m, region_n)
% layout is opposite direction of matlab normal
% |  1  2  3  4 |
% |  5  6  7  8 |
% |  9 10 11 12 |
% | 13 14 15 16 |

region_mask_m = zeros(SLMm, SLMn);
region_mask_n = zeros(SLMm, SLMn);

for n_col = 1:SLMn
    region_mask_n(:,n_col) = ceil(n_col/SLMn*region_n)-1;
end
for n_row = 1:SLMm
    region_mask_m(n_row,:) = ceil(n_row/SLMm*region_m)-1;
end

pixel_region_idx = region_mask_m*region_n + region_mask_n;

end