function f_sg_pp_clear_pts(app)

if ~isempty(app.app_main.UIImagePhaseTable.Data.Idx)
    app.app_main.UIImagePhaseTable.Data(:,:) = [];
    f_sg_pp_update_pat_plot(app);
end

end