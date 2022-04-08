function f_plot_lut_corr(lut_input)

px_plot = [1, 51, 101, 151, 201, 256];

lut_corr = lut_input;
if isstruct(lut_input)
    if isfield(lut_input, 'lut_corr')
        lut_corr = lut_input.lut_corr;
    end
end

for n_px = 1:numel(px_plot)
    figure;
    imagesc(lut_corr(:,:,px_plot(n_px)))
    colorbar;
    title(sprintf('pixel srip = %d', px_plot(n_px)-1))
end


end