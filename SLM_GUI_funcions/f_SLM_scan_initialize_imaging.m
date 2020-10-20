function f_SLM_scan_initialize_imaging(app)

if app.InitializeimagingButton.Value
    try
        disp('Initializing multiplane imaging...');
        plane_table = app.UIImagePhaseTable.Data(:,:).Variables;
        planes = unique (plane_table(:,1));
        num_planes = numel(planes);
        volumes = app.NumVolumesEditField.Value;
        num_planes_all = num_planes*volumes;
        
        %% compute patterns
        holo_pointers = cell(num_planes,1);
        for n_pl = 1:num_planes
            holo_pointers{n_pl} = f_SLM_initialize_pointer(app);

            curr_plane = planes(n_pl);
            plane_subtable = plane_table(plane_table(:,1) == curr_plane,:);

            holo_image = f_SLM_PhaseHologram_YS([plane_subtable(:,3:4), plane_subtable(:,2)*10e-6],...
                                            app.SLMheightEditField.Value,...
                                            app.SLMwidthEditField.Value,...
                                            plane_subtable(:,6),...
                                            plane_subtable(:,5),...
                                            app.ObjectiveRIEditField.Value,...
                                            app.WavelengthnmEditField.Value*10e-9);
            holo_image = f_SLM_AO_add_correction(app,holo_image);
            holo_pointers{n_pl} = f_SLM_convert_to_pointer(app, holo_image);                
        end
        
        app.ImagingReadyLamp.Color = [0.00,1.00,0.00];
        
        f_SLM_EOF_scan(app, holo_pointers, num_planes_all, app.InitializeimagingButton);
        
        app.InitializeimagingButton.Value = 0;
        app.ImagingReadyLamp.Color = [0.80,0.80,0.80];
        
    catch
        app.InitializeimagingButton.Value = 0;
        app.ImagingReadyLamp.Color = [0.80,0.80,0.80];
        disp('Imaging run failed')
        f_SLM_BNS_update(app.SLM_ops, app.SLM_blank_pointer);
    end
else
    app.ImagingReadyLamp.Color = [0.80,0.80,0.80];
end


end