function Y_sm = f_smooth_movie(Y, smooth_std)

siz = size(Y);
smooth_std1 = smooth_std;
siz1 = siz;
Y_sm = Y;

for n_sm = 1:3
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

        for nd2 = 1:siz1(2)
            for nd3 = 1:siz1(3)
                line_data = squeeze(double(Y_sm(:, nd2, nd3)));
                line_data_sm = conv(line_data, gaus_kernel, 'same')./norm_line_sm;
                Y_sm(:, nd2, nd3) = uint16(line_data_sm);
            end
        end

    end
    smooth_std1 = smooth_std1([2 3 1]);
    siz1 = siz1([2 3 1]);
    Y = permute(Y, [2 3 1]);
    Y_sm = permute(Y_sm, [2 3 1]);
end

end