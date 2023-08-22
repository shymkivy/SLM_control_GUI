function mask_all = f_sg_xyz_make_pt_image(reg1, coord_corr, make_disk, disc_size)

if ~exist("make_disk", 'var')
    make_disk = 0;
end
if ~exist("disc_size", 'var')
    disc_size = 5;
end

z_all = unique(coord_corr.xyzp(:,3));
num_z = numel(z_all);

FOV_size = reg1.FOV_size;

%ph_d = reg1.phase_diameter;
%x_coord = round(((1:siz)-(siz/2)-1)/2/siz*ph_d,2);
%y_coord = round(((1:siz)-(siz/2)-1)/2/siz*ph_d,2);

x_coord = linspace(-FOV_size/2, FOV_size/2, reg1.SLMn);
y_coord = linspace(-FOV_size/2, FOV_size/2, reg1.SLMm);
[X,Y] = meshgrid(x_coord,y_coord);
xy_coord = [X(:), Y(:)];

% mask_disk = zeros(siz, siz);
% euc_dist_zero = sqrt(sum((xy_coord).^2,2));
% idx_disc = euc_dist_zero < disc_size;
% mask_disk(idx_disc) = 1;

mask_all = zeros(reg1.SLMm, reg1.SLMn, num_z);

for n_z = 1:num_z
    idx1 = coord_corr.xyzp(:,3) == z_all(n_z);
    xyzp2 = coord_corr.xyzp(idx1,:);
    I1P = coord_corr.I_targ1P(idx1);
    num_pts2 = size(xyzp2,1);
    for n_pt = 1:num_pts2
        temp_fr = mask_all(:,:,n_z);
        xyzp3 = xyzp2(n_pt,:);
        euc_dist = sqrt(sum((xyzp3(1:2) - xy_coord).^2,2));
        [~, idx_cent] = min(euc_dist);
        
        temp_fr(idx_cent) = I1P(n_pt);

        if make_disk
            idx_disc = euc_dist < disc_size;
            temp_fr(idx_disc) = I1P(n_pt);
        end

        mask_all(:,:,n_z) = temp_fr;
    end
end

end