function f_sg_plot_stim_pattern_trace(app)

[stim_patterns, stim_times] = f_sg_gen_custom_stim_times(app, app.PatternDropDownAI.Value);

if ~isempty(stim_patterns)
    trace1 = zeros(max(stim_times),1);
    trace1(stim_times) = stim_patterns;

    figure;
    plot((1:max(stim_times))/1000, trace1);
    title('custom stim trace');
    xlabel('sec')
    ylabel('stim_type')
    axis tight;
else
    disp('No patterns')
end

end