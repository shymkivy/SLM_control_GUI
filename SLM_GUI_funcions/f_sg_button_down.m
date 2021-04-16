function f_sg_button_down(app, src)

cent = [256, 256]/2;

idx1 = false(numel(src.Children),1);
for n_ch = 1:numel(src.Children)
    idx1(n_ch) = strcmpi(src.Children(n_ch).Type, 'axes');
end
idx2 = find(idx1);
ax1 = src.Children(idx2(1));
info = get(ax1);
coord_plane = round(info.CurrentPoint(1,1:2));

tab_data = app.UIImagePhaseTable.Data.Variables;

if isempty(tab_data)
    idx = 1;
else
    idx = size(tab_data,1)+1;
    tab_data(:,1) = 1:(idx-1);
end

f_sg_xyz_create_pt(ax1, coord_plane, idx, app);

app.UIImagePhaseTable.Data = array2table([tab_data;...
            idx,...
            app.PatternnumberEditField.Value,...
            app.planezSpinner.Value,...
            coord_plane(1) - cent(1),...
            coord_plane(2) - cent(2),...
            app.ManualNAEditField.Value,...
            app.WeightEditField.Value]);


end