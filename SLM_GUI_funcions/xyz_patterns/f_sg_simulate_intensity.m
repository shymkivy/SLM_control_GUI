function data_out = f_sg_simulate_intensity(reg1, SLM_phase, coord, point_size, gauss_input, estimate_2p_int, plot_stuff)

if ~exist('plot_stuff', 'var')
    plot_stuff = 0;
end

xyz_temp = [coord.xyzp; [0 0 0]];
all_z = unique(xyz_temp(:,3));

num_pts = size(xyz_temp,1);
num_z = numel(all_z);

pt_mags = zeros(num_pts,1);
pt_abs_err = zeros(num_pts,1);

z_bkg = zeros(num_z,1);
z_pts = zeros(num_z,1);
im_sum = zeros(num_z,1);

for n_z = 1:num_z
    [im_amp, x_coord, y_coord] = f_sg_compute_holo_fft(reg1, SLM_phase, all_z(n_z), [], gauss_input);
    
    if estimate_2p_int
        im_amp = im_amp.^2;
        title_tag = '2P intens';
    else
        title_tag = '1P intens';
    end
    
    idx1 = xyz_temp(:,3)==all_z(n_z);
    
    xyz_temp2 = xyz_temp(idx1,:);
    num_pts2 = sum(idx1);
    
    %
    % FOV_size = reg1.FOV_size;
    % 
    % %ph_d = reg1.phase_diameter;
    % %x_coord = round(((1:siz)-(siz/2)-1)/2/siz*ph_d,2);
    % %y_coord = round(((1:siz)-(siz/2)-1)/2/siz*ph_d,2);
    % 
    % x_coord = linspace(-FOV_size/2, FOV_size/2, reg1.SLMn);
    % y_coord = linspace(-FOV_size/2, FOV_size/2, reg1.SLMm);
    % [X,Y] = meshgrid(x_coord,y_coord);
    % xy_coord = [X(:), Y(:)];

    
    % x_coord = round(((1:reg1.SLMn)-(reg1.SLMn/2)-1)/2/reg1.SLMn*ph_d,2);
    % y_coord = round(((1:reg1.SLMm)-(reg1.SLMm/2)-1)/2/reg1.SLMm*ph_d,2);
    % 

    [X,Y] = meshgrid(x_coord,y_coord);
    xy_coord = [X(:), Y(:)];
 
    im_amp2 = im_amp;

    idx_all = cell(num_pts2,1);
    pt_mags1 = zeros(num_pts2,1);
    pt_abs_err1 = zeros(num_pts2,1);

    for n_pt = 1:num_pts2
        euc_dist = sqrt(sum((xyz_temp2(n_pt,1:2) - xy_coord).^2,2));
        idx2 = euc_dist <= point_size;
        peak_vals = im_amp(idx2);
        pt_mags1(n_pt) = sum(peak_vals);
        peak_mean = mean(peak_vals);
        pt_abs_err1(n_pt) = mean(abs(peak_vals - peak_mean))/peak_mean*100;

        im_amp2(idx2) = 0;

        idx_all{n_pt} = idx2;
    end
    
    pt_mags(idx1) = pt_mags1;
    pt_abs_err(idx1) = pt_abs_err1;
    
    z_pts(n_z) = num_pts2-1;
    z_bkg(n_z) = sum(im_amp2(:));
    im_sum(n_z) = sum(im_amp(:));


    if plot_stuff
        figure; hold on;
        im1 = imagesc(x_coord, y_coord, im_amp);
        for n_pt = 1:num_pts2
            plot(xy_coord(idx_all{n_pt},1), xy_coord(idx_all{n_pt},2), '.r')
            %rectangle('Position', [xyz_temp2(n_pt,1)-distx/2 xyz_temp2(n_pt,2)-distx/2 2*distx/2 2*distx/2]);
        end
        axis equal tight
        im1.Parent.YDir = 'reverse';
        %clim([0 .01])
        title(sprintf('%s estimate; z = %.1f; pix dist %d', title_tag, all_z(n_z), point_size));
    end
end

data_out.pt_mags = pt_mags(1:end-1);
data_out.pt_abs_err = pt_abs_err(1:end-1);
data_out.zero_ord_mag = pt_mags(end);
data_out.coord = coord;
data_out.zero_zoord = [0 0 0];
data_out.z_pts = z_pts;
data_out.z_bkg = z_bkg;
data_out.im_sum = im_sum;


if plot_stuff
    figure; plot(pt_mags)
end
end