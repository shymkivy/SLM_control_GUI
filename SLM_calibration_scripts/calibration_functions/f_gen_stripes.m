function stripes = f_gen_stripes(SLMm, SLMn, pix_per_stripe, is_horizontal)

if ~exist('is_horizontal', 'var')
    is_horizontal = 0;
end

stripes = zeros(SLMm, SLMn);
if is_horizontal
    for n_pix = 1:SLMm
        stripes(n_pix,:) = rem(ceil(n_pix/pix_per_stripe),2);
    end
else
    for n_pix = 1:SLMn
        stripes(:,n_pix) = rem(ceil(n_pix/pix_per_stripe),2);
    end
end

end