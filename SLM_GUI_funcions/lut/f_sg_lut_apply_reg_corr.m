function holo_corr = f_sg_lut_apply_reg_corr(SLM_phase, reg1)
% apply lut correction for current region

% convert full phase to 256int
temp_holo = uint8(((SLM_phase+pi)/(2*pi))*255);

if ~isempty(reg1.lut_correction_data)
    
    lut_corr = round(reg1.lut_correction_data);

    if numel(lut_corr) == 256
        holo_corr = uint8(lut_corr(temp_holo+1));
    else
        [SLMrm, SLMrn,~] = size(lut_corr);
        [SLMm, SLMn] = size(temp_holo);
        holo_corr = zeros(SLMm, SLMn, 'uint8');

        m_fac = SLMm/SLMrm;
        n_fac = SLMn/SLMrn;
        for n_m = 1:SLMm
            for n_n = 1:SLMn
                holo_corr(n_m, n_n) = lut_corr(ceil(n_m/m_fac), ceil(n_n/n_fac),temp_holo(n_m, n_n)+1);
            end
        end
    end
    % corr resuduals
    % figure; imagesc(temp_holo_corr-temp_holo)
else
    holo_corr = temp_holo;
end

end