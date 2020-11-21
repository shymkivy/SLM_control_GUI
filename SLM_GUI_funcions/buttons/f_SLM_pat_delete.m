function f_SLM_pat_delete(app)

idx1 = strcmpi(app.PatterngroupDropDown.Value, [app.xyz_patterns.name_tag]);

if sum(idx1)
    if numel(idx1)>1
        app.xyz_patterns(idx1) = [];
        app.PatterngroupDropDown.Items(idx1) = [];
        app.PatternDropDownCtr.Items = [{'None'}, app.xyz_patterns.name_tag];
        app.PatternDropDownAI.Items = [{'None'}, app.xyz_patterns.name_tag];
    else
        disp('Need to keep at least one')
    end
    f_SLM_pat_update(app)
else
    disp('Pattern delete failed')
end

end