function holo_image = f_sg_gen_holo_multiplane_image(app, coord, reg1)

SLMm = sum(reg1.m_idx);
SLMn = sum(reg1.n_idx);

xyzp = coord.xyzp;
num_points = size(xyzp,1);

weight = coord.weight;
beam_diameter = reg1.beam_diameter;

if num_points>1
    if numel(weight) == 1
        weight = ones(num_points,1)*weight;
    end
end

holo_image = f_sg_PhaseHologram(xyzp, SLMm,SLMn,weight,...
                    coord.NA,...
                    app.ObjectiveRIEditField.Value,...
                    reg1.wavelength*1e-9,...
                    beam_diameter);
               
holo_image(~reg1.holo_mask) = 1;
    
end