function holo_pointer_value = f_sg_im_to_pointer_lut_corr(holo_image, lut_corr_data) % , m_idx, n_idx
% needs regional correction plus location index

if ~exist('lut_corr_data', 'var')   
    lut_corr_data = [];
end

if isempty(lut_corr_data)
    temp_holo = uint8((rot90(holo_image, 3)/(2*pi))*255);
else
    temp_holo1 = uint8((holo_image/(2*pi))*255);
    
    for n_corr = 1:size(lut_corr_data,1)
        if ~isempty(lut_corr_data(n_corr).lut_corr)
            lut_corr = round(lut_corr_data(n_corr).lut_corr);
            m_idx = lut_corr_data(n_corr).m_idx;
            n_idx = lut_corr_data(n_corr).n_idx;

            temp_holo2 = temp_holo1;
            temp_holo2(~m_idx,:) = [];
            temp_holo2(:,~n_idx) = [];

            if numel(lut_corr) == 256
                temp_holo_corr = lut_corr(temp_holo2+1);
            else
                [SLMrm, SLMrn,~] = size(lut_corr);
                [SLMm, SLMn] = size(temp_holo2);
                temp_holo_corr = zeros(SLMm, SLMn, 'uint8');

                m_fac = SLMm/SLMrm;
                n_fac = SLMn/SLMrn;
                for n_m = 1:SLMm
                    for n_n = 1:SLMn
                        temp_holo_corr(n_m, n_n) = lut_corr(ceil(n_m/m_fac), ceil(n_n/n_fac),temp_holo1(n_m, n_n)+1);
                    end
                end
            end
            temp_holo1(m_idx,n_idx) = temp_holo_corr;
        end
    end
    temp_holo = rot90(temp_holo1, 3);
end
holo_pointer_value = reshape(temp_holo, [],1);

end