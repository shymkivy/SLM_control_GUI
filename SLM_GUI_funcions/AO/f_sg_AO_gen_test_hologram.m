function [holo_phase_out, n, m] = f_sg_AO_gen_test_hologram(app)

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
[m_idx, n_idx] = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);
        
SLMm = sum(m_idx);
SLMn = sum(n_idx);

beam_diameter = max([SLMm SLMn]);

xlm = linspace(-SLMm/beam_diameter, SLMm/beam_diameter, SLMm);
xln = linspace(-SLMn/beam_diameter, SLMn/beam_diameter, SLMn);

[fX, fY] = meshgrid(xln, xlm);
[theta, rho] = cart2pol( fX, fY );

weight = app.weightEditField.Value;
mode_index = app.ModeindexEditField.Value;

zernike_data = app.ZernikeListTable.Data;
n = zernike_data(mode_index,2);
m = zernike_data(mode_index,3);

[Z_nm, ~, ~] = f_sg_zernike_pol(rho, theta, n, m);
if app.ZerooutsideunitcircCheckBox.Value
    Z_nm(rho>1) = 0;
end

phase = Z_nm*weight;

phase = angle(exp(1i*(phase))) + pi;

holo_phase_out = app.SLM_blank_phase;
holo_phase_out(m_idx, n_idx) = phase;
% convert to 8bit
%phase8bit = round(phase/2/pi*255);
end