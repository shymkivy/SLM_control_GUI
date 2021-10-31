function [m_idx, n_idx, reg1] = f_sg_get_reg_deets(app, name_tag)

% get slm region
idx_reg = strcmpi(name_tag, [app.region_list.reg_name]);
reg1 = app.region_list(idx_reg);
m = reg1.height_range;
n = reg1.width_range;

m_px = (1:app.SLM_ops.height)'/app.SLM_ops.height;
n_px = (1:app.SLM_ops.width)'/app.SLM_ops.width;

m_idx = logical((m_px>m(1)).*(m_px<=m(2)));
n_idx = logical((n_px>n(1)).*(n_px<=n(2)));

reg1 = app.region_list(idx_reg);
reg1.m_idx = m_idx;
reg1.n_idx = n_idx;

SLMm = sum(m_idx);
SLMn = sum(n_idx);
xlm = linspace(-SLMm/reg1.beam_diameter, SLMm/reg1.beam_diameter, SLMm);
xln = linspace(-SLMn/reg1.beam_diameter, SLMn/reg1.beam_diameter, SLMn);
[fX, fY] = meshgrid(xln, xlm);
[~, RHO] = cart2pol(fX, fY);
holo_mask = true(SLMm, SLMn);

if app.ZerooutsideunitcircCheckBox.Value
    holo_mask(RHO>1) = 0;
end

reg1.holo_mask = holo_mask;

end