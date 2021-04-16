function f_sg_LUT_update_total_frames(app)

bit_depth = app.BitDepthEditField.Value;
num_regions = app.NumRegionsEditField.Value;

total_frames = bit_depth*num_regions;

if app.InsertrefimageinscansCheckBox.Value
    total_frames = total_frames + 2*num_regions;
end

app.TotalframesEditField.Value = total_frames;

end