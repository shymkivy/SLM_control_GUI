function rel_offset = f_compute_holo_offset(WFC_in, tol)

[d1, d2] = size(WFC_in);
curr_off = 0;
rel_offset = zeros(d1, d2);
for p1 = 2:d1
    if (WFC_in(p1,1) - WFC_in(p1-1,1)) > tol
        curr_off = curr_off - 1;
    end
    if (WFC_in(p1,1) - WFC_in(p1-1,1)) < -tol
        curr_off = curr_off + 1;
    end
    rel_offset(p1,1) = curr_off;
end
for p1 = 1:d1
    for p2 = 2:d2
        curr_off = rel_offset(p1, p2-1);
        if (WFC_in(p1,p2) - WFC_in(p1,p2-1)) > tol
            curr_off = curr_off - 1;
        end
        if (WFC_in(p1,p2) - WFC_in(p1,p2-1)) < -tol
            curr_off = curr_off + 1;
        end
        rel_offset(p1,p2) = curr_off;
    end
end

end