function [ defocus ] = f_sg_DefocusPhase2(reg_params)

SLMm = sum(reg_params.m_idx);
SLMn = sum(reg_params.n_idx);
objectiveNA = reg_params.effective_NA;
objectiveRI = reg_params.objective_RI;
illuminationWavelength = reg_params.wavelength*1e-9;

if isfield(reg_params, 'phase_diameter')
    phase_diameter = reg_params.phase_diameter;
else
    phase_diameter = max(SLMn,SLMm);
end

%max_dim = max(SLMn,SLMm);

xlm = linspace(-SLMm/phase_diameter, SLMm/phase_diameter, SLMm);
xln = linspace(-SLMn/phase_diameter, SLMn/phase_diameter, SLMn);
[fX, fY] = meshgrid(xln, xlm);
[~, RHO] = cart2pol( fX, fY );

%alpha = asin((objectiveNA./objectiveRI));
k = 2*pi/illuminationWavelength;
sin_alpha = objectiveNA/objectiveRI;

% from doi.org/10.1016/j.optcom.2007.10.007
phase = objectiveRI * k * sqrt(1 - RHO.^2 * sin_alpha^2);

% first strategy, can compute area by summing the pixels, but SLM region
% may not have equal m and n ... not sure which way is correct yet
% bias is integral / area of unit circle, which is pi
% d_SLMm = (2*SLMm/phase_diameter)/SLMm;
% d_SLMn = (2*SLMn/phase_diameter)/SLMn;
% bias = sum(phase(RHO<=1)*(d_SLMm)*(d_SLMn))/pi;

% second strategy, approximate area of the phase, for full phase
% d_rho = 1e-5;
% Rho2 = 0:d_rho:1;
% % defocus equation
% phase2 = objectiveRI * k * sqrt(1 - Rho2.^2 * sin_alpha^2);
% bias = sum(phase2.* Rho2 * 2 * pi * d_rho)/pi;

% third strategy, from integal of taylor expansion of phase equation
% phase =  z * objectiveRI * k * (1 - Rho.^2*sin_alpha^2/2 - Rho.^4*sin_alpha^4/8 - Rho.^4*sin_alpha^6/16)
% bias = objectiveRI*k*(1 - sin_alpha^2/4 - sin_alpha^4/24 - sin_alpha^6/64 - sin_alpha^8/128); 

% best strategy
% the full unaproximated bias, from integrating over the phase function
% is also in doi.org/10.1016/j.optcom.2007.10.007
cos_alpha = cos(asin(sin_alpha));
bias = (2*objectiveRI*k)/(3*sin_alpha^2)*(1 - cos_alpha^3);

% defocus is phase with bias subtracted
defocus = -(phase - bias);

% approximation
%defocus = -objectiveRI * k * (1 - RHO.^2 * (objectiveNA/objectiveRI)^2 / 2 - RHO.^4 * (objectiveNA/objectiveRI)^4 / 8);
%defocus = -objectiveRI * k * ((objectiveNA/objectiveRI)^2/4 - RHO.^2 * (objectiveNA/objectiveRI)^2 / 2 - RHO.^4 * (objectiveNA/objectiveRI)^4 / 8);


% this is now formated for exp(i*defocus*z)

end