function f_sg_pp_add_grid(app)

numX = app.numXEditField.Value;
spacX = app.spacingXEditField.Value;
shiftX = app.shiftXEditField.Value;

numY = app.numYEditField.Value;
spacY = app.spacingYEditField.Value;
shiftY = app.shiftYEditField.Value;


[X, Y] = meshgrid(linspace(-spacX*(numX-1)/2-shiftX, spacX*(numX-1)/2-shiftX, numX),...
                  linspace(-spacY*(numY-1)/2-shiftY, spacY*(numY-1)/2-shiftY, numY));
              
coords = [X(:), Y(:)];

num_pts = numel(X);

tab_data = app.app_main.UIImagePhaseTable.Data;

if isempty(tab_data.Pattern)
    pat_shift = 0;
else
    pat_shift = max(tab_data.Pattern);
end

if app.SamepatternCheckBox.Value
    curr_pat = ones(num_pts,1)*app.PatternSpinner.Value;
else
    curr_pat = (1:num_pts)' + pat_shift;
end


new_row1 = [ones(num_pts,1),...
            curr_pat,...
            coords(:,1),...
            coords(:,2),...
            ones(num_pts,1)*app.ZdepthSpinner.Value,...
            ones(num_pts,1)];

new_row2 = array2table(new_row1);
new_row2.Properties.VariableNames = tab_data.Properties.VariableNames;

tab_data2 = [tab_data;new_row2];

[~, idx1] = sort(tab_data2(:,2).Variables);

tab_data3 = tab_data2(idx1,:);

tab_data3(:,1).Variables = (1:numel(tab_data3(:,1).Variables))';

app.app_main.UIImagePhaseTable.Data = tab_data3;

f_sg_pp_update_pat_plot(app);

end