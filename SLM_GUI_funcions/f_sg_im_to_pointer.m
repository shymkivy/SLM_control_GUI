function holo_pointer_value = f_sg_im_to_pointer(holo_image, lut_correction)
if ~exist('lut_correction', 'var')    
    temp_holo = uint8((rot90(holo_image, 3)/(2*pi))*255);
else
    temp_holo1 = uint8((holo_image/(2*pi))*255);
    lut_corr = round(lut_correction);
    [SLMm, SLMn] = size(temp_holo1);
    [SLMrm, SLMrn,~] = size(lut_corr);
    temp_holo_corr = zeros(SLMm, SLMn, 'uint8');
    m_fac = SLMm/SLMrm;
    n_fac = SLMn/SLMrn;
    for n_m = 1:SLMm
        for n_n = 1:SLMn
            temp_holo_corr(n_m, n_n) = lut_corr(ceil(n_m/m_fac), ceil(n_n/n_fac),temp_holo1(n_m, n_n)+1);
        end
    end
    temp_holo = rot90(temp_holo_corr, 3);
end
holo_pointer_value = reshape(temp_holo, [],1);

end