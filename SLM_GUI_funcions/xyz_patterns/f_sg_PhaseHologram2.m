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

alpha = asin(reg_params.effective_NA/reg_params.objective_RI);
f_obj = 0.180/25;

reg_params2 = reg_params;
for idx=1:size(xyzp,1)
    
    % adjust NA by z depth
    z = xyzp(3)*1e-6;
    f_obj_corr = f_obj + z;
    alpha_corr = atan(tan(alpha)*f_obj/f_obj_corr);
    NA_corr = reg_params.objective_RI * sin(alpha_corr);
    reg_params2.effective_NA = NA_corr;

    %defocus_phase = f_sg_DefocusPhase(reg_params2);
    defocus_phase = f_sg_DefocusPhase2(reg_params2);

    holo_phase(:,:,idx)=2*pi.*xyzp(idx,1).*u ...
                      + 2*pi.*xyzp(idx,2).*v ...
                      + xyzp(idx,3)*1e-6.*defocus_phase;
end

end
