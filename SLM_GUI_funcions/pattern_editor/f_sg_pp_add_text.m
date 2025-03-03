function f_sg_pp_add_text(app, field_name, x_pos, y_pos, text_val, color1, checkbox)

num_pts = numel(x_pos);
if isfield(app.data, field_name)
    num_txt = numel(app.data.(field_name));
    for n_pt = 1:num_txt
        app.data.(field_name){n_pt}.reset
    end
    if num_pts > num_txt
        app.data.(field_name) = [app.data.(field_name); cell(num_pts-num_txt,1)];
        for n_pt = max(num_txt,1):num_pts
            app.data.(field_name){n_pt} = text(app.UIAxes);
        end
    end
else
    app.data.(field_name) = cell(num_pts,1);
    for n_pt = 1:num_pts
        app.data.(field_name){n_pt} = text(app.UIAxes);
    end
end
if checkbox.Value
    for n_pt = 1:num_pts
        app.data.(field_name){n_pt}.Position = [x_pos(n_pt), y_pos(n_pt), 0];
        if iscell(text_val(n_pt))
            app.data.(field_name){n_pt}.String = text_val{n_pt};
        else
            app.data.(field_name){n_pt}.String = num2str(text_val(n_pt));
        end
        app.data.(field_name){n_pt}.Color = color1;
    end
end
end