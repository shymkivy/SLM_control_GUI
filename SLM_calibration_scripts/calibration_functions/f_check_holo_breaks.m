function has_breaks = f_check_holo_breaks(curr_pix, ref_pix, image_in, period)
has_breaks = 0;

dist1 = sqrt(sum((ref_pix - curr_pix).^2));
vec_u = (ref_pix - curr_pix)/dist1;
num_vals = floor(floor(dist1)/period);
if num_vals
    vals1 = zeros(num_vals+1,1);
    for ii = 0:num_vals
        ii2 = ii*period;
        vec1 = ii2*vec_u;
        coord_curr = round(curr_pix + vec1);
        vals1(ii+1) = image_in(coord_curr(1), coord_curr(2));
    end
    if sum(vals1<1)
        has_breaks = 1;
    end
end

end
