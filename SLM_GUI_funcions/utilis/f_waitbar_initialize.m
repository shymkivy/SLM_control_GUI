function wb = f_waitbar_initialize(app, text)

wb = struct;
if ~exist('app', 'var') || isempty(app)
    wb.h = waitbar(0,text);
    wb.new_fig = 1;
else
    wb.fw = app.UIFigure;
    wb.new_fig = 0;
    wb.handlew = uiprogressdlg(wb.fw,'Title', text);
end    

pause(0.05);


end