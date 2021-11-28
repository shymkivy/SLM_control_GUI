function [ phase ] = f_sg_PhaseHologram(xyzp, SLMm, SLMn, weight, objectiveNA, objectiveRI, illuminationWavelength, beam_diameter)
%F_SLM_PHASEHOLOGRAM Summary of this function goes here
% xyz are in um
%   Detailed explanation goes here
    
if ~exist('beam_diameter', 'var')
    beam_diameter = max(SLMn,SLMm);
end

xlm = linspace(-SLMm/beam_diameter, SLMm/beam_diameter, SLMm);
xln = linspace(-SLMn/beam_diameter, SLMn/beam_diameter, SLMn);
[u, v] = meshgrid(xln, xlm);

% max_dim = max(SLMn,SLMm);
% [ u, v ] = meshgrid(linspace(-SLMn/max_dim,SLMn/max_dim,SLMn), linspace(-SLMm/max_dim,SLMm/max_dim,SLMm));

SLMplane=0;
defocus=zeros(SLMm, SLMn, size(xyzp,1));
if nargin<4
    weight=zeros(1,size(xyzp,1))+1;
end
if nargin>4
    for idx=1:size(xyzp,1)
        defocus(:,:,idx) = SLMMicroscope_DefocusPhase(SLMm, SLMn, objectiveNA, objectiveRI, illuminationWavelength, beam_diameter);
    end
end
for idx=1:size(xyzp,1)
    SLMplane=SLMplane+exp(1i.*(2*pi.*xyzp(idx,1).*u ...
                          + 2*pi.*xyzp(idx,2).*v ...
                          + xyzp(idx,3)*1e-6.*defocus(:,:,idx)))*weight(idx);
end
phase=SLMplane;
end

function [ defocus ] = SLMMicroscope_DefocusPhase( SLMm, SLMn, objectiveNA, objectiveRI, illuminationWavelength, beam_diameter)
    if ~exist('beam_diameter', 'var')
        beam_diameter = max(SLMn,SLMm);
    end
    
    xlm = linspace(-SLMm/beam_diameter, SLMm/beam_diameter, SLMm);
    xln = linspace(-SLMn/beam_diameter, SLMn/beam_diameter, SLMn);
    [fX, fY] = meshgrid(xln, xlm);

%     max_dim = max(SLMn,SLMm);
%     xlm = linspace(-SLMm/max_dim, SLMm/max_dim, SLMm);
%     xln = linspace(-SLMn/max_dim, SLMn/max_dim, SLMn);
%     [fX, fY] = meshgrid(xln, xlm);
    
    [~, RHO] = cart2pol( fX, fY );
    
    alpha = asin( (objectiveNA./objectiveRI) );
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