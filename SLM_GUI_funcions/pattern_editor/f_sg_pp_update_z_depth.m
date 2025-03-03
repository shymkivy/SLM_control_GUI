function f_sg_pp_update_z_depth(app, event)
% Updates the Z-depth spinner.
%   To allow for variable step size, the z-depth spinner implementation
% iterates through an index of z-depths rather than the z-depths 
% themselves. The value displayed in the field is the z-depth[index], and
% therefore remains the z-depth value of the currently selected plane.

z_all = app.ZdepthSpinner.UserData;

last_z = event.PreviousValue;
last_index = find(z_all == last_z);

if isempty(last_index)
    return
else
    current_value = event.Value;
    delta_index = current_value - last_z;
    
    % Because -20 is up
    current_index = last_index + delta_index * -1;

    current_z_depth = z_all(current_index);
    app.ZdepthSpinner.Value = current_z_depth;

end

