function custom_stim = f_sg_gen_custom_stim_times(app, pat_name)

idx1 = strcmpi({app.xyz_patterns.pat_name}, pat_name);

custom_stim = struct();

if sum(idx1)
    if ~isempty(app.xyz_patterns(idx1).xyz_pts)
        tab_data = app.xyz_patterns(idx1).xyz_pts;
        
        pat_all = unique(tab_data.Pattern);
        init_delay = app.initialdelayEditField.Value;
        num_rep = app.patternrepeatsEditField.Value;
        duration = app.patterndurationEditField.Value;
        isi = app.patternintervalEditField.Value;
        isi_jitter = app.patternintervaljitterEditField.Value; 

        pat_all2 = reshape(repmat(pat_all', [num_rep, 1]), [], 1);
        if strcmpi(app.patternorderDropDown.Value, 'random')
            pat_all2 = pat_all2(randperm(numel(pat_all2)));
        end

        num_tr = numel(pat_all2);
        stim_times = zeros(num_tr,1);
        stim_times(1) = round(init_delay*1000);
        for n_tr = 2:num_tr
            shift = round((duration + isi + rand(1)*isi_jitter)*1000);
            stim_times(n_tr) = stim_times(n_tr-1) + shift;
        end
        
        trace1 = zeros(round(max(stim_times)+(duration + isi + isi_jitter)*1000),1);
        for n_st = 1:numel(stim_times)
            trace1(stim_times(n_st):(stim_times(n_st)+round(duration*1000))) = pat_all2(n_st);
        end
        
        custom_stim.stim_times = stim_times;
        custom_stim.stim_patterns = pat_all2;
        custom_stim.stim_trace = trace1;
    end
end

end