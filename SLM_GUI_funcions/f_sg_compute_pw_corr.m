function pw_corr_data = f_sg_compute_pw_corr(app, reg_params, plot_stuff)

if ~exist('plot_stuff', 'var')
    plot_stuff = 0;
end

pw_corr_data = [];
if app.ApplyPWcorrectionButton.Value
    pw_corr_fname = reg_params.point_weight_correction_fname;
    if isempty(pw_corr_fname)
        pw_corr_data = [];
    elseif strcmpi(reg_params.point_weight_correction_fname, 'none')
        pw_corr_data = [];
    else
        data = load([app.SLM_ops.point_weight_correction_dir '\' reg_params.point_weight_correction_fname]);
        if isstruct(data.weight_cal)
            pw_params.min_w_thesh = app.PWmincorrthreshEditField.Value;
            pw_params.smooth_std = ones(1,2)*app.PWsmoothstdEditField.Value;
            
            coords_x = data.weight_cal.coords_x;
            coords_y = data.weight_cal.coords_y;
            pw_data = data.weight_cal.weight_means_2d;
            
%             [X,Y] = meshgrid(coords_x,coords_y);
%             [sf,gof,output] = fit([X(:), Y(:)],pw_data(:),'poly22')
%             pw_data_fit = sf.p00 + sf.p10*X + sf.p01*Y + sf.p20*X.^2 + sf.p11*X.*Y + sf.p02*Y.^2;
%             pw_data_sm = f_smooth_nd(pw_data, pw_params.smooth_std);
            
            % pad data
            pw_data_pad = padarray(pw_data,[1 1],'replicate','both');
            
            half_fov = ceil(app.FOVsizeumEditField.Value/2);
            
            if min(coords_x) > -half_fov
                coords_x = [-half_fov, coords_x];
            else
                pw_data_pad(:,1) = [];
            end
            
            if max(coords_x) < half_fov
                coords_x = [coords_x, half_fov];
            else
                pw_data_pad(:,end) = [];
            end
            
            if min(coords_y) > -half_fov
                coords_y = [-half_fov, coords_y];
            else
                pw_data_pad(1,:) = [];
            end
            
            if max(coords_y) < half_fov
                coords_y = [coords_y, half_fov];
            else
                pw_data_pad(end,:) = [];
            end

            [X,Y] = meshgrid(coords_x,coords_y);
            
            % reset min
            pw_data_pad2 = pw_data_pad;
            pw_data_pad2(pw_data_pad<pw_params.min_w_thesh) = pw_params.min_w_thesh;
            
            % smooth
            pw_data_sm = f_smooth_nd(pw_data_pad2, pw_params.smooth_std);
            
            % interpolate
            coords_x_ip = linspace(min(coords_x), max(coords_x), max(coords_x) - min(coords_x) + 1);
            coords_y_ip = linspace(min(coords_y), max(coords_y), max(coords_y) - min(coords_y) + 1);
            [X_ip,Y_ip] = meshgrid(coords_x_ip,coords_y_ip);
            pw_data_ip = interp2(X, Y, pw_data_sm, X_ip, Y_ip);
            
            % save
            pw_corr_data = struct();
            pw_corr_data.pw_map_2d = pw_data_ip;
            pw_corr_data.x_coord = coords_x_ip;
            pw_corr_data.y_coord = coords_y_ip;
            pw_corr_data.pw_params = pw_params;
            
            if plot_stuff
                figure;
                subplot(2,2,1);
                imagesc(coords_y, coords_x, pw_data_pad); caxis([0 1]); axis equal tight
                title('data raw padded');
                subplot(2,2,2);
                imagesc(coords_y_ip, coords_x_ip, pw_data_pad2); caxis([0 1]); axis equal tight
                title(sprintf('data padded, thresh=%.1f', pw_params.min_w_thesh));
                subplot(2,2,3);
                imagesc(coords_y, coords_x, pw_data_sm); caxis([0 1]); axis equal tight
                title(sprintf('data smooth, std = [%.1f, %.1f]',pw_params.smooth_std(1), pw_params.smooth_std(2)));
                subplot(2,2,4);
                imagesc(coords_y_ip, coords_x_ip, pw_data_ip); caxis([0 1]); axis equal tight
                title(sprintf('data interp, thresh=%.1f', pw_params.min_w_thesh));
                sgtitle(reg_params.reg_name)
            end
        end
    end
end

end