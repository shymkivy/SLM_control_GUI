function f_SLM_button_down(app, src)

info = get(src.Children);
coord = round(info.CurrentPoint(1,1:2));

%plot(src.Children, coord(1), coord(2), 'o')

images.roi.Point(src.Children, 'Color', 'r', 'Position',[coord(1), coord(2)]);

end