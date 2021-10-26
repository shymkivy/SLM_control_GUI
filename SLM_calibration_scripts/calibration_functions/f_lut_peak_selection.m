function min_max_min_ind = f_lut_peak_selection(lut_trace, params)

if ~exist('params', 'var')
    params = struct;
end

if isfield(params, 'order')
    order = params.order;
else
    order = 1; % default is first order, zero order flips graph
end

if isfield(params, 'smooth_win')
    smooth_win = params.smooth_win;
else
    smooth_win = 0;
end

if isfield(params, 'plot_stuff')
    plot_stuff = params.plot_stuff;
else
    plot_stuff = 0;
end

if isfield(params, 'manual_selection')
    manual_selection = params.manual_selection;
else
    manual_selection = 0;
end

extend_mins = 0;
if smooth_win
    lut_trace_s = smoothdata(lut_trace, 2, 'gaussian', smooth_win);
else
    lut_trace_s = lut_trace;
end

%%
px = 1:numel(lut_trace);

if extend_mins
    max_rise_thresh = .1;
    min_fall_rise_thresh = 10;
end

min_max_min_ind = zeros(3,1);

if manual_selection
    peak_buff = 10;
    f1 = figure; hold on; axis tight;
    plot(px, lut_trace);
    plot(px, lut_trace_s);
    
    if order
        title('First order, select first min for 0 pi');
    else
        title('Zero order, select first max for 0 pi');
    end
    [x,~] = ginput(1);
    x = round(x)+1;
    [~, min_ind1] = min(lut_trace_s((x-peak_buff):(x+peak_buff)));
    min_max_min_ind(1) = min_ind1 + x - peak_buff - 1;
    
    if order
        title('First order, select max for 1 pi');
    else
        title('Zero order, select min for 1 pi');
    end
    [x,~] = ginput(1);
    x = round(x)+1;
    [~, max_ind] = max(lut_trace_s((x-peak_buff):(x+peak_buff)));
    min_max_min_ind(2) = max_ind + x - peak_buff - 1;
    
    if order
        title('First order, select second min for 2 pi');
    else
        title('Zero order, select second max for 2 pi');
    end
    [x,~] = ginput(1);
    x = round(x)+1;
    [~, min_ind2] = min(lut_trace_s((x-peak_buff):(x+peak_buff)));
    min_max_min_ind(3) = min_ind2 + x - peak_buff - 1;
    
    close(f1)
else  
    num_pts = numel(lut_trace_s);
    diffrns = diff(lut_trace_s);
    
    min_max = false(num_pts,1);
    for n_pt = 2:(num_pts-1)
        min_max(n_pt) = logical(abs(sign(diffrns(n_pt)) - sign(diffrns(n_pt-1))));
    end
    
    points2 = [1; find(min_max); num_pts];
    
    sets = zeros(numel(points2)-2,3);
    for n_pt = 1:(numel(points2)-2)
        if lut_trace_s(points2(n_pt)) < lut_trace_s(points2(n_pt+1))
            sets(n_pt,:) = [n_pt, n_pt+1, n_pt+2];
        end
    end
    sets(~logical(sum(sets,2)),:) = [];
    
    set_vals = lut_trace_s(points2(sets));
    
    if size(set_vals,1)>1
        [~, best_set_idx] = max(sum(abs(diff(set_vals,[],2)) .* diff(points2(sets), [],2),2));
    else
        [~, best_set_idx] = max(sum(abs(diff(set_vals,[],2)) .* diff(points2(sets)', [],2),2));
    end
    
    best_set = sets(best_set_idx,:);
    
    if extend_mins
        % extend left side 
        done = 0;
        while ~done
            if (best_set(1) - 2) > 0
                int_rise = lut_trace_s(points2(best_set(1)-1))-lut_trace_s(points2(best_set(1)));
                int_fall = lut_trace_s(points2(best_set(1)-1)) - lut_trace_s(points2(best_set(1)-2));
                if and((int_fall/int_rise)>min_fall_rise_thresh,int_rise<max_rise_thresh)
                    best_set(1) = best_set(1) - 2;
                else
                    done = 1;
                end
            else
                done = 1;
            end
        end

        % extend right side
        done = 0;
        while ~done
            if (best_set(3) + 2) <= max(sets(:))
                int_rise = lut_trace_s(points2(best_set(3) + 1))-lut_trace_s(points2(best_set(3)));
                int_fall = lut_trace_s(points2(best_set(3) + 1)) - lut_trace_s(points2(best_set(3) + 2));
                if and((int_fall/int_rise)>min_fall_rise_thresh,int_rise<max_rise_thresh)
                    best_set(3) = best_set(3) + 2;
                else
                    done = 1;
                end
            else
                done = 1;
            end
        end
    end
    min_max_min_ind = points2(best_set);
%     
%     best_trio = zeros(3,1);
%     for n_pt = 1:(numel(points2)-2)
%         if lut_trace_s(points2(n_pt))<lut_trace_s(points2(n_pt+1))
%             best_trio(1) = points2(n_pt);
%             best_trio(2) = points2(n_pt+1);
%         end
%     end
%     
%     data_fo_rns_auto(points2)
%     
%     rem_pts = false(size(points1,1),1);
%     for n_pt = 2:(size(points1,1)-2)
%         min_max(n_pt) = logical(abs(sign(diffrns(n_pt)) - sign(diffrns(n_pt-1))));
%     end
% 
%     if size(sets,1) > 1
%         1;
%         params.plot_stuff = 1;
%     end
% 
%     [min_val2, min_ind2] = min(data_fo_rns2(max_ind:end));
%     min_ind2 = min_ind2 + max_ind - 1;
%     [min_val1, min_ind1] = min(data_fo_rns2(1:max_ind));
end

%%
if plot_stuff
    figure; hold on;
    plot(px, lut_trace);
    plot(px, lut_trace_s);
    plot(min_max_min_ind, lut_trace_s(min_max_min_ind), 'ro', 'LineWidth', 2);
    if order
        title('First order, 0, pi, 2pi');
    else
        title('Zero order, , 0, pi, 2pi');
    end
end
