function [ defocus ] = f_sg_DefocusPhase_YS( SLMm, SLMn, objectiveNA, objectiveRI, illuminationWavelength, beam_width)

if ~exist('beam_width', 'var')
    beam_width = max(SLMn,SLMm);
end
%max_dim = max(SLMn,SLMm);

xlm = linspace(-SLMm/beam_width, SLMm/beam_width, SLMm);
xln = linspace(-SLMn/beam_width, SLMn/beam_width, SLMn);
[fX, fY] = meshgrid(xln, xlm);
[~, RHO] = cart2pol( fX, fY );

alpha = asin((objectiveNA./objectiveRI));
k = 2*pi/illuminationWavelength;

% from 'Three dimensional imaging and photostimulation by remote focusing and holographic light patterning'
c_0_2 = ( objectiveRI*k*(sin(alpha)^2)/(8*pi*sqrt(3)) ).*( 1 + (1/4)*(sin(alpha)^2) + (9/80)*(sin(alpha)^4) + (1/16)*(sin(alpha)^6) );
c_0_4 = ( objectiveRI*k*(sin(alpha)^4)/(96*pi*sqrt(5)) ).*( 1 + (3/4)*(sin(alpha)^2) + (15/18)*(sin(alpha)^4) );
c_0_6 = ( objectiveRI*k*(sin(alpha)^6)/(640*pi*sqrt(7)) ).*( 1 + (5/4)*(sin(alpha)^2) );
Z_0_2 = sqrt(3).*( 2.*RHO.^2 - 1 );
Z_0_4 = sqrt(5).*( 6.*RHO.^4 - 6.*RHO.^2 + 1 );
Z_0_6 = sqrt(7).*( 20.*RHO.^6 - 30.*RHO.^4 + 12.*RHO.^2 - 1 );

%     figure; subplot(1,3,1); imagesc(Z_0_2.*(RHO<=1)); axis image; colorbar;
%        subplot(1,3,2); imagesc(Z_0_4.*(RHO<=1)); axis image; colorbar;
%        subplot(1,3,3); imagesc(Z_0_6.*(RHO<=1)); axis image; colorbar;
%     figure; imagesc(RHO); axis image; colorbar;
%dsp_debug on line below can include HOA corrections...
%    defocus = 2*pi.*(c_0_2.*Z_0_2 + c_0_4.*Z_0_4 );%+ c_0_6.*Z_0_6;
defocus = 2*pi.*(c_0_2.*Z_0_2 + c_0_4.*Z_0_4 + c_0_6.*Z_0_6);
%    defocus = -objectiveRI*k*sqrt(1-RHO.^2.*(sin(alpha)^2));

% this is now formated for exp(i*defocus*z)
end