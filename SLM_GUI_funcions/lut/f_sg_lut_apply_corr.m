function f_sg_lut_apply_corr(app)
% apply lut correction for current region
% from app.SLM_phase_corr to app.SLM_phase_corr_lut

[m_idx, n_idx, reg1] = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);

% get current lut corr data
lut_data = [];
if ~isempty(reg1.lut_correction_data)
    lut_data2(1).lut_corr = reg1.lut_correction_data;
    lut_data2(1).m_idx = m_idx;
    lut_data2(1).n_idx = n_idx;
    lut_data = [lut_data; lut_data2];
end

% convert full phase to 256int
temp_holo = uint8(((app.SLM_phase+pi)/(2*pi))*255);

if ~isempty(lut_data)
    temp_holo1 = temp_holo;
    
    for n_reg = 1:size(lut_data,1)
        if ~isempty(lut_data(n_reg).lut_corr)
            lut_corr = round(lut_data(n_reg).lut_corr);
            m_idx = lut_data(n_reg).m_idx;
            n_idx = lut_data(n_reg).n_idx;

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
    % corr resuduals
    % figure; imagesc(temp_holo1-temp_holo)
    app.SLM_phase_lut_corr = temp_holo1;
else
    app.SLM_phase_lut_corr = temp_holo;
end

end