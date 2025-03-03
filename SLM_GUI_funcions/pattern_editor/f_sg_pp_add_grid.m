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
    idx_shift = 0;
else
    pat_shift = max(tab_data.Pattern);
    idx_shift = max(tab_data.Idx);
end

if app.SamepatternCheckBox.Value
    curr_pat = ones(num_pts,1)*app.PatternSpinner.Value;
else
    curr_pat = (1:num_pts)' + pat_shift;
end

new_rows = f_sg_initialize_tabxyz(app.app_main, num_pts);
new_rows.Idx = new_rows.Idx + idx_shift;
new_rows.Pattern = curr_pat;
new_rows.X = coords(:,1);
new_rows.Y = coords(:,2);
new_rows.Z = ones(num_pts,1)*app.ZdepthSpinner.Value;

tab_data2 = [tab_data;new_rows];

[~, idx1] = sort(tab_data2(:,2).Variables);

tab_data3 = tab_data2(idx1,:);

tab_data3(:,1).Variables = (1:numel(tab_data3(:,1).Variables))';

app.app_main.UIImagePhaseTable.Data = tab_data3;

f_sg_pp_update_pat_plot(app);

end