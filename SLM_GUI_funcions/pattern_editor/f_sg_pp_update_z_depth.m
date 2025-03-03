function f_sg_pp_update_z_depth(app, event)
% Updates the Z-depth spinner.
%   To allow for variable step size, the z-depth spinner implementation
% iterates through an index of z-depths rather than the z-depths 
% themselves. The value displayed in the field is the z-depth[index], and
% therefore remains the z-depth value of the currently selected plane.

z_all = app.ZdepthSpinner.UserData;

last_value = event.PreviousValue;
last_index = find(z_all == last_value);

if isempty(last_index)
    return
else
    current_value = event.Value;
    % Because -20 is up
    if current_value < last_value
        delta_index = -1;
    elseif current_value > last_value
        delta_index = 1;
    else
        delta_index = 0;
    end
    current_index = last_index + delta_index;
    current_z_depth = z_all(current_index);
    app.ZdepthSpinner.Value = current_z_depth;

end

