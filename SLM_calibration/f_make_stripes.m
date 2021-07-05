function stripes_out = f_make_stripes(siz_m, siz_n, pix_width)


stripes_out = zeros(siz_m, siz_n);

for n_pix = 1:siz_n
    if (rem(n_pix-1, pix_width*2)+1) > pix_width
        stripes_out(:,n_pix) = 1;
    end
end


end