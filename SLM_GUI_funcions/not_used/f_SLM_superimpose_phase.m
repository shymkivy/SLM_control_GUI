function phase_out = f_SLM_superimpose_phase(phases_in, weights)
    
    if ~exist('weights', 'var'); weights = ones(numel(phases_in),1); end
    phase_out_temp = zeros(size(phases_in{1}));
    
    for ii = 1:numel(phases_in)
        phase_out_temp = phase_out_temp + exp(1i.*(phases_in{ii}-pi))*weights(ii);
    end
    
    phase_out = angle(phase_out_temp)+pi;

%     SLMplane=SLMplane+exp( 1i.*(2*pi.*xyzp(idx,1).*u ...
%                               + 2*pi.*xyzp(idx,2).*v ...
%                               + xyzp(idx,3).*defocus(:,:,idx)) )*weight(idx);
%     figure; imagesc(phase_out); axis image

end