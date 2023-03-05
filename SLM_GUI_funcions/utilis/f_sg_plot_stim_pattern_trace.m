function f_sg_plot_stim_pattern_trace(app)

custom_stim = f_sg_gen_custom_stim_times(app, app.PatternDropDownAI.Value);

if isfield(custom_stim, 'stim_trace')

    figure;
    plot((1:numel(custom_stim.stim_trace))/1000, custom_stim.stim_trace);
    title('custom stim trace');
    xlabel('sec')
    ylabel('stim_type')
    axis tight;
else
    disp('No patterns')
end

end