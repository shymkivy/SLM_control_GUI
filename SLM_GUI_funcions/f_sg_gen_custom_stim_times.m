function [stim_patterns, stim_times] = f_sg_gen_custom_stim_times(app, pat_name)

idx1 = strcmpi({app.xyz_patterns.pat_name}, pat_name);

stim_patterns = [];
stim_times = [];

if sum(idx1)
    if ~isempty(app.xyz_patterns(idx1).xyz_pts)
        tab_data = app.UIImagePhaseTable.Data;
        
        pat_all = unique(tab_data.Pattern);
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
        stim_times(1) = round(isi*1000);
        for n_tr = 2:num_tr
            shift = round((duration + isi + rand(1)*isi_jitter)*1000);
            stim_times(n_tr) = stim_times(n_tr-1) + shift;
        end

        stim_patterns = pat_all2;
    end
end

end