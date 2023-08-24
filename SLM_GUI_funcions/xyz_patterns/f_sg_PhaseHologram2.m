function holo_phase = f_sg_PhaseHologram2(coord, reg_params)
% most code here adopted from Weijian Yang slm gui

xyzp = coord.xyzp;
SLMm = reg_params.SLMm;
SLMn = reg_params.SLMn;

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

%defocus_phase = f_sg_DefocusPhase(reg_params);
defocus_phase = f_sg_DefocusPhase2(reg_params);

for idx=1:num_pts
    holo_phase(:,:,idx)=2*pi.*xyzp(idx,1).*u ...
                      + 2*pi.*xyzp(idx,2).*v ...
                      + xyzp(idx,3)*1e-6.*defocus_phase;
end

% holo_phase2 = 2*pi.*(reshape(xyzp(:,1), 1, 1, []).*u...
%                     + reshape(xyzp(:,2), 1, 1, []).*v)...
%                     + reshape(xyzp(:,3), 1, 1, [])*1e-6.*defocus_phase;

end
