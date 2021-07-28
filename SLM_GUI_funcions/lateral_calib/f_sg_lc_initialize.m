function f_sg_lc_initialize(app)

app.data.plot_im = imagesc(app.UIAxes, []);
hold(app.UIAxes, 'on');
axis(app.UIAxes, 'tight');
axis(app.UIAxes, 'equal');
app.data.plot_zo = plot(app.UIAxes, 0, 0, 'og');
app.data.plot_fo = plot(app.UIAxes, 0, 0, 'or');
app.data.plot_zo.XData = [];
app.data.plot_zo.YData = [];
app.data.plot_fo.XData = [];
app.data.plot_fo.YData = [];
app.data.plot_zo.MarkerSize = 10;
app.data.plot_zo.LineWidth = 1;
app.data.plot_fo.MarkerSize = 10;
app.data.plot_fo.LineWidth = 1;
end