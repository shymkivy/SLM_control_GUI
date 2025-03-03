function f_sg_pp_update_colormap(app)
%F_SG_PP_SWAP_COLORMAP Swap colormap

cmap = app.current_colormap;
if length(cmap) <= 5 && contains(cmap, '_R')
    cmap = split(cmap, '_');
    cmap = colorcet(cmap{1}, 'reverse', 1);
elseif length(cmap) <= 3 && contains(cmap, 'L')
    cmap = colorcet(cmap);
end
colormap(app.UIAxes, cmap);

end

