function holo_phase = f_sg_PhaseHologram2(coord, reg_params)
% most code here adopted from Weijian Yang slm gui

xyzp = coord.xyzp;
SLMm = sum(reg_params.m_idx);
SLMn = sum(reg_params.n_idx);

if isfield(reg_params, 'phase_diameter')
    phase_diameter = reg_params.phase_diameter;
else
    phase_diameter = max(SLMn,SLMm);
end

xlm = linspace(-SLMm/phase_diameter, SLMm/phase_diameter, SLMm);
xln = linspace(-SLMn/phase_diameter, SLMn/phase_diameter, SLMn);
[u, v] = meshgrid(xln, xlm);

% max_dim = max(SLMn,SLMm);
% [ u, v ] = meshgrid(linspace(-SLMn/max_dim,SLMn/max_dim,SLMn), linspace(-SLMm/max_dim,SLMm/max_dim,SLMm));

num_points = size(xyzp,1);

holo_phase = zeros(SLMm, SLMn, num_points);

num_pts = size(xyzp,1);

for idx=1:num_pts
    
    %defocus_phase = f_sg_DefocusPhase(reg_params);
    defocus_phase = f_sg_DefocusPhase2(reg_params);

    holo_phase(:,:,idx)=2*pi.*xyzp(idx,1).*u ...
                      + 2*pi.*xyzp(idx,2).*v ...
                      + xyzp(idx,3)*1e-6.*defocus_phase;
end

end
