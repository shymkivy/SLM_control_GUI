function corr_out = f_sg_AO_condense_corr(corr_in)

max_mode = max(corr_in(:,1));
corr_out = zeros(max_mode, 2);

for n_mode = 1:max_mode
    corr_out(n_mode,1) = n_mode;
    idx1 = corr_in(:,1) == n_mode;
    if sum(idx1)
        w = sum(corr_in(idx1,2));
        corr_out(n_mode,2) = w;
    end
end

end