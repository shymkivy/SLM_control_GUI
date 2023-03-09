function holo_pix_out = f_apply_lut_corr(SLM_phase, lut_corr_data)

if ~exist('lut_corr_data', 'var')
    lut_corr_data = [];
end

%temp_holo1 = uint8(SLM_phase);
temp_holo1 = uint8(((SLM_phase+pi)/(2*pi))*255);

if ~isempty(lut_corr_data)
    for n_corr = 1:size(lut_corr_data,1)
        if ~isempty(lut_corr_data(n_corr).lut_corr)
            lut_corr = round(lut_corr_data(n_corr).lut_corr);
            m_idx = logical(lut_corr_data(n_corr).m_idx);
            n_idx = logical(lut_corr_data(n_corr).n_idx);

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
                        temp_holo_corr(n_m, n_n) = lut_corr(ceil(n_m/m_fac), ceil(n_n/n_fac),temp_holo2(n_m, n_n)+1);
                    end
                end
            end
            temp_holo1(m_idx,n_idx) = temp_holo_corr;
        end
    end
end

holo_pix_out = temp_holo1;

end
