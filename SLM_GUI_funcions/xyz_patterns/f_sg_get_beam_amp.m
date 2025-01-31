function pupil_amp = f_sg_get_beam_amp(reg1, use_gauss)

dims = [reg1.SLMm, reg1.SLMn];
ph_d = reg1.phase_diameter;

% beam shape
if use_gauss
    Lx = linspace(-dims(2)/ph_d, dims(2)/ph_d, dims(2));
    Ly = linspace(-dims(1)/ph_d, dims(1)/ph_d, dims(1));
    sigma = 1;
    
    %Lx = linspace(-(siz-1)/2,(siz-1)/2,siz);
    %sigma = reg1.beam_diameter/2; 			% beam waist/2
    
    [c_X, c_Y] = meshgrid(Lx, Ly);
    x0 = 0;                 % beam center location
    y0 = 0;                 % beam center location
    A = 1;                  % peak of the beam 
    res = ((c_X-x0).^2 + (c_Y-y0).^2)./(2*sigma^2);
    pupil_amp = A  * exp(-res);
else
    pupil_amp = ones(dims);
end

pupil_amp = pupil_amp/sum(pupil_amp(:));

% removed because amp is not clipped in path
% if reg1.zero_outside_phase_diameter
%     pupil_amp = pupil_amp .* reg1.holo_mask;
% end

end