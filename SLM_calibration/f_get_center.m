function cent_mn = f_get_center(im)

cent_mn = zeros(2,1);
[~, peak_ind] = max(im(:));
[cent_mn(1),cent_mn(2)] = ind2sub(size(im),peak_ind);

end
