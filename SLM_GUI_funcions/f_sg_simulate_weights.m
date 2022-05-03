function data_out = f_sg_simulate_weights(reg1, SLM_phase, coord)

pt_hsize = 4;
plot_stuff = 0;

xyz_temp = [coord.xyzp; [0 0 0]];
all_z = unique(xyz_temp(:,3));
pt_mags = zeros(size(xyz_temp,1),1);

for n_z = 1:numel(all_z)
    [im_amp, xy_axis] = f_sg_compute_holo_fft(reg1, SLM_phase, all_z(n_z));
    
    im_amp = im_amp.^2;
    
    idx1 = xyz_temp(:,3)==all_z(n_z);
    
    xyz_temp2 = xyz_temp(idx1,:);
    num_pts = sum(idx1);
    
    [~, x_coord_idx] = min((xyz_temp2(:,1) - xy_axis).^2, [], 2);
    [~, y_coord_idx] = min((xyz_temp2(:,2) - xy_axis).^2, [], 2);
    
    
    pt_mags1 = zeros(num_pts,1);
    for n_pt = 1:num_pts
        im1 = im_amp((y_coord_idx(n_pt)-pt_hsize):(y_coord_idx(n_pt)+pt_hsize),...
                     (x_coord_idx(n_pt)-pt_hsize):(x_coord_idx(n_pt)+pt_hsize));
        pt_mags1(n_pt) = sum(im1(:));
        %figure; imagesc(im1)
    end
    
    pt_mags(idx1) = pt_mags1;
    
    if plot_stuff
        figure; hold on;
        imagesc(xy_axis, xy_axis, im_amp)
        for n_pt = 1:num_pts
            rectangle('Position', [xyz_temp2(n_pt,1)-pt_hsize xyz_temp2(n_pt,2)-pt_hsize 2*pt_hsize 2*pt_hsize])
        end
        axis equal tight
        caxis([0 .01])
        title(sprintf('z = %.1f', all_z(n_z)));
    end
end

data_out.pt_mags = pt_mags(1:end-1);
data_out.zero_ord_mag = pt_mags(end);
data_out.coord = coord;
data_out.zero_zoord = [0 0 0];

if plot_stuff
    figure; plot(pt_mags)
end
end