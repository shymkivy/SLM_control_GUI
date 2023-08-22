function data_out = f_sg_simulate_intensity(reg1, SLM_phase, coord, point_size)

plot_stuff = 0;

xyz_temp = [coord.xyzp; [0 0 0]];
all_z = unique(xyz_temp(:,3));
pt_mags = zeros(size(xyz_temp,1),1);

for n_z = 1:numel(all_z)
    [im_amp, x_lab, y_lab] = f_sg_compute_holo_fft(reg1, SLM_phase, all_z(n_z), [], app.UsegaussianbeamampCheckBox.Value);
    
    im_amp = im_amp.^2;
    
    idx1 = xyz_temp(:,3)==all_z(n_z);
    
    xyz_temp2 = xyz_temp(idx1,:);
    num_pts = sum(idx1);
    
    distx = point_size/reg1.SLMn*(x_lab(end) - x_lab(1));
    disty = point_size/reg1.SLMn*(y_lab(end) - y_lab(1));
    x_idx = and(x_lab >= (xyz_temp2(:,1) - distx/2), x_lab <= (xyz_temp2(:,1) + distx/2));
    y_idx = and(y_lab >= (xyz_temp2(:,2) - disty/2), y_lab <= (xyz_temp2(:,2) + disty/2));

    pt_mags1 = zeros(num_pts,1);
    for n_pt = 1:num_pts
        im1 = im_amp(y_idx(n_pt,:), x_idx(n_pt,:));
        pt_mags1(n_pt) = sum(im1(:));
        %figure; imagesc(im1)
    end
    
    pt_mags(idx1) = pt_mags1;
    
    if plot_stuff
        figure; hold on;
        imagesc(x_lab, y_lab, im_amp)
        for n_pt = 1:num_pts
            rectangle('Position', [xyz_temp2(n_pt,1)-distx/2 xyz_temp2(n_pt,2)-distx/2 2*distx/2 2*distx/2]);
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