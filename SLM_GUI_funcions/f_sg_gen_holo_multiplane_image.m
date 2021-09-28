function holo_image = f_sg_gen_holo_multiplane_image(app, coord, SLMm, SLMn)
    
    if ~exist('SLMm', 'var')
        SLMm = app.SLMheightEditField.Value;
        SLMn = app.SLMwidthEditField.Value;
    end
    
    xyzp = coord.xyzp;
    num_points = size(xyzp,1);
    
    weight = coord.weight;
    objectiveNA = coord.NA;
    
    if num_points>1
        if numel(weight) == 1
            weight = ones(num_points,1)*weight;
        end
        if numel(objectiveNA) == 1
            objectiveNA = ones(num_points,1)*objectiveNA;
        end
    end
    
    objectiveRI = app.ObjectiveRIEditField.Value;
    illuminationWavelength = app.WavelengthnmEditField.Value*1e-9;
    beam_width = app.BeamdiameterpixEditField.Value;
    
    holo_image = f_sg_PhaseHologram_YS(xyzp, SLMm,SLMn,weight,objectiveNA,objectiveRI,illuminationWavelength, beam_width);
    
    if app.AOzerooutsideunitcircCheckBox.Value
        xlm = linspace(-SLMm/beam_width, SLMm/beam_width, SLMm);
        xln = linspace(-SLMn/beam_width, SLMn/beam_width, SLMn);
        [fX, fY] = meshgrid(xln, xlm);
        [~, RHO] = cart2pol(fX, fY);
        holo_image(RHO>1) = 1;
    end
    
%    SLM_phase = zeros(SLMm, SLMn, num_points);
%     for n_point = 1:num_points
%         SLM_phase(:,:,n_point) = f_sg_PhaseHologram_YS(xyzp(n_point,:), SLMm,SLMn,weight(n_point),objectiveNA(n_point),objectiveRI,illuminationWavelength);
%     end
%    holo_image=angle(sum(exp(1i*(SLM_phase)),3))+pi;  %%% wrrong <--------
end