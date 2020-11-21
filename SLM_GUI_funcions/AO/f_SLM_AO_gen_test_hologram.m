function [phase, n, m] = f_SLM_AO_gen_test_hologram(app)

% Z0_0    = 1;
% Z1_n1   = 2*rho.*sin(theta);
% Z1_1    = 2*rho.*cos(theta);
% Z2_n2   = sqrt(6)*rho.^2.*sin(theta);
% Z2_0    = sqrt(3)*(2*rho.^2 - 1);
% Z2_2    = sqrt(6)*rho.^2.*cos(2*theta);
% Z3_n3   = sqrt(8)*rho.^3.*sin(3*theta);
% Z3_n1   = sqrt(8)*(3*rho.^3 - 2*rho).*sin(theta);
% Z3_1    = sqrt(8)*(3*rho.^3 - 2*rho).*cos(theta);
% Z3_3    = sqrt(8)*rho.^3.*cos(3*theta);
% Z4_n4   = sqrt(10)*rho.^4.*sin(4*theta);
% Z4_n2   = sqrt(10)*(4*rho.^4 - 3.*rho.^2).*sin(2*theta);
% Z4_0    = sqrt(5)*(6*rho.^4 - 6*rho.^2 + 1);
% Z4_2    = sqrt(10)*(4*rho.^4 - 3.*rho.^2).*cos(2*theta);
% Z4_4    = sqrt(10)*rho.^4.*cos(4*theta);

% generate coordinates
SLMn = app.SLM_ops.width;
SLMm = app.SLM_ops.height;
beam_width = app.BeamdiameterpixEditField.Value;
xlm = linspace(-SLMm/beam_width, SLMm/beam_width, SLMm);
xln = linspace(-SLMn/beam_width, SLMn/beam_width, SLMn);
[fX, fY] = meshgrid(xln, xlm);
[theta, rho] = cart2pol( fX, fY );

weight = app.weightEditField.Value;
mode_index = app.ModeindexEditField.Value;

zernike_data = app.ZernikeListTable.Data;
n = zernike_data(mode_index,2);
m = zernike_data(mode_index,3);

[Z_nm, ~, ~] = f_SLM_zernike_pol(rho, theta, n, m);

phase = angle(exp(1i*Z_nm*weight)) + pi;
% convert to 8bit
%phase8bit = round(phase/2/pi*255);
end