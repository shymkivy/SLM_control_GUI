function data_out = f_sg_simulate_intensity(reg1, SLM_phase, coord, point_size, gauss_input, estimate_2p_int, plot_stuff)

if ~exist('plot_stuff', 'var')
    plot_stuff = 0;
end

xyz_temp = [coord.xyzp; [0 0 0]];
all_z = unique(xyz_temp(:,3));
pt_mags = zeros(size(xyz_temp,1),1);

ph_d = reg1.phase_diameter;

for n_z = 1:numel(all_z)
    [im_amp, x_coord, y_coord] = f_sg_compute_holo_fft(reg1, SLM_phase, all_z(n_z), [], gauss_input);
    
    if estimate_2p_int
        im_amp = im_amp.^2;
        title_tag = '2P intens';
    else
        title_tag = '1P intens';
    end
    
    idx1 = xyz_temp(:,3)==all_z(n_z);
    
    xyz_temp2 = xyz_temp(idx1,:);
    num_pts = sum(idx1);
    
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
    
    dx = ph_d/2/max([reg1.SLMn, reg1.SLMm]);
    % dx = ph_d/2/reg1.SLMn;
    % dy = ph_d/2/reg1.SLMm;

    idx_all = cell(num_pts,1);
    pt_mags1 = zeros(num_pts,1);
    for n_pt = 1:num_pts
        euc_dist = sqrt(sum((xyz_temp2(n_pt,1:2) - xy_coord).^2,2));
        idx2 = euc_dist <= dx*point_size;
        pt_mags1(n_pt) = sum(im_amp(idx2));
        idx_all{n_pt} = idx2;
    end

    pt_mags(idx1) = pt_mags1;
    
    if plot_stuff
        figure; hold on;
        im1 = imagesc(x_coord, y_coord, im_amp);
        for n_pt = 1:num_pts
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
data_out.zero_ord_mag = pt_mags(end);
data_out.coord = coord;
data_out.zero_zoord = [0 0 0];

if plot_stuff
    figure; plot(pt_mags)
end
end