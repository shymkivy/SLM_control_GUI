function data_sm = f_smooth_nd(data, smooth_std)

num_dims = ndims(data);
data_type = class(data);
siz = size(data);
smooth_std1 = smooth_std;
siz1 = siz;
data_sm = data;
dims_list = 1:num_dims;

for n_sm = 1:num_dims
    if smooth_std1(1)>0
        % make kernel
        sm_std1 = smooth_std1(1);
        kernel_half_size = ceil(sqrt(-log(0.05)*2*sm_std1^2));
        gaus_win = -kernel_half_size:kernel_half_size;
        gaus_kernel = exp(-((gaus_win).^2)/(2*sm_std1^2));
        gaus_kernel = gaus_kernel/sum(gaus_kernel);
        
        %figure; plot(gaus_kernel)
        
        norm_line = ones(siz1(1),1);
        norm_line_sm = conv(norm_line, gaus_kernel, 'same');
        
        temp_size = size(data_sm);
        
        data_sm_s2 = reshape(data_sm, temp_size(1), []);
        
        temp_size2 = size(data_sm_s2);
        
        if strcmpi(data_type, 'uint16')
            for nd2 = 1:temp_size2(2)
                line_data = squeeze(double(data_sm_s2(:, nd2)));
                line_data_sm = conv(line_data, gaus_kernel, 'same')./norm_line_sm;
                data_sm_s2(:, nd2) = uint16(line_data_sm);
            end
        elseif strcmpi(data_type, 'uint8')
            for nd2 = 1:temp_size2(2)
                line_data = squeeze(double(data_sm_s2(:, nd2)));
                line_data_sm = conv(line_data, gaus_kernel, 'same')./norm_line_sm;
                data_sm_s2(:, nd2) = uint8(line_data_sm);
            end
        else
            for nd2 = 1:temp_size2(2)
                line_data = squeeze(data_sm_s2(:, nd2));
                line_data_sm = conv(line_data, gaus_kernel, 'same')./norm_line_sm;
                data_sm_s2(:, nd2) = line_data_sm;
            end
        end
        data_sm = reshape(data_sm_s2, temp_size);
        
    end
    dims_list2 = circshift(dims_list,-1);
    
    smooth_std1 = smooth_std1(dims_list2);
    siz1 = siz1(dims_list2);
    data = permute(data, dims_list2);
    data_sm = permute(data_sm, dims_list2);
end

end