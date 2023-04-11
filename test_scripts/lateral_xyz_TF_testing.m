clear;
close all


objectiveRI = 1.33;
objectiveNA_20 = 0.415; % 0.48;
objectiveNA_25 = 0.565; %0.61;
%sin_alpha = objectiveNA_20/objectiveRI;
k = 2*pi/940e-9;


fname1 = 'xyz_calib_20x_fianium_z1_12_21_20.mat';
fname2 = 'xyz_calib_25x_fianium_11_11_21.mat';

data1 = load(fname1);
data2 = load(fname2);


xyz1 = data1.xyz_affine_calib;
xyz2 = data2.xyz_affine_calib;


disp_xy = (xyz1.first_ord_coords - xyz1.zero_ord_coords)*xyz1.pix_step_xy;
input1 = xyz1.input_coords(:,1:2);

disp_mag = sqrt(sum(disp_xy.^2,2));
in_mag = sqrt(sum(input1.^2,2));

reg1 = in_mag\disp_mag;

if xyz1.y_flip_bug
    input1(:,2) = -input1(:,2);
end

lateral_affine_tf = input1\disp_xy;

lateral_affine_tf_inv = inv(lateral_affine_tf);

% eigenvectors
[V,D,W] = eig(lateral_affine_tf_inv);

eigenal1 = (objectiveNA_20*k*1e-6)/(2*pi);

eigenal1*((.83333+1)/2)

comp_eff_NA1 = rms(diag(D))/(k*1e-6)*2*pi;


[theta, rho] = cart2pol(-100, 0)


disp_xy2 = (xyz2.first_ord_coords - xyz2.zero_ord_coords)*xyz2.pix_step_xy;
input2 = xyz2.input_coords(:,1:2);
lateral_affine_tf2 = input2\disp_xy2;

lateral_affine_tf_inv2 = inv(lateral_affine_tf2);

[V2,D2,W2] = eig(lateral_affine_tf_inv2);

eigenal2 = (objectiveNA_25*k*1e-6)/(2*pi);

rho = 1;
theta = 0:0.1:(2*pi);

figure; hold on;
for n_coord = 1:numel(theta)
    [x, y] = pol2cart(theta(n_coord), rho);
    xy_tf = [x, y]*lateral_affine_tf_inv;
    plot([x, xy_tf(1)], [y, xy_tf(2)], 'k');
    plot(x, y, 'ko');
end

