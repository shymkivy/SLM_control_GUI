function [holo_phase, coord_corr] = f_sg_xyz_gen_holo(coord, reg1)

%% xyz calib
coord_corr = coord;
coord_corr.xyzp = (coord.xyzp+reg1.xyz_offset)*reg1.xyz_affine_tf_mat;

%% expand weights
% num_points = size(coord.xyzp,1);
% weight = coord.weight;
% if num_points>1
%     if numel(weight) == 1
%         weight = ones(num_points,1)*weight;
%     end
% end

%% generate holo (need to apply AO separately for each)          
holo_phase = f_sg_PhaseHologram2(coord_corr, reg1);

end