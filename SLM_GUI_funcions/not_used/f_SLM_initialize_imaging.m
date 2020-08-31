function f_SLM_initialize_imaging(app)
if app.InitializeimagingButton.Value
    try
        app.abort_imaging = 0;
        plane_table = app.UIImagePhaseTable.Data(:,:).Variables;
        planes = unique (plane_table(:,1));
        num_planes = numel(planes);
        volumes = app.VolumesEditField.Value;

        %% compute patterns
        holo_pointers = cell(num_planes,1);
        for n_pl = 1:num_planes
            holo_pointers{n_pl} = f_initialize_pointer(app);


            curr_plane = planes(n_pl);
            plane_subtable = plane_table(plane_table(:,1) == curr_plane,:);

            holo_image = f_SLM_PhaseHologram_YS([plane_subtable(:,3:4), plane_subtable(:,2)*10e-6],...
                                            app.SLMheightEditField.Value,...
                                            app.SLMwidthEditField.Value,...
                                            plane_subtable(:,6),...
                                            plane_subtable(:,5),...
                                            app.ObjectiveRIEditField.Value,...
                                            app.WavelengthnmEditField.Value*10e-9);
            holo_pointers{n_pl} = f_SLM_convert_to_pointer(app, holo_image);                
        end
        disp('Holograms created');

        % initialize DAQ
        session = daq.createSession ('ni');
        % Setup counter, PFI12
        addCounterInputChannel(session, app.NIDAQdeviceEditField.Value, 'ctr0', 'EdgeCount');
        resetCounters(session);
        inputSingleScan(session);

        disp('DAQ initialized');

        app.ImagingReadyLamp.Color = [0.00,1.00,0.00];
        pause(0.05);
        disp('Ready');
        f_SLM_update_YS(app.SLM_ops, holo_pointers{1}); 
        
        imaging = 1;
        SLM_frame = 1;
        while imaging
            scan_frame = inputSingleScan(session)+1;
            if scan_frame > SLM_frame
                f_SLM_update_YS(app.SLM_ops, holo_pointers{rem(scan_frame-1,num_planes)+1});
                SLM_frame = scan_frame;
            end
            if scan_frame > (num_planes*volumes)
                imaging = 0;
            end
            if app.abort_imaging
                imaging = 0;
            end
        end
        
%         for n_vol = 1:volumes
%             for n_pl = 1:num_planes
%                 while inputSingleScan(session)==0
%                 end
%                 f_SLM_update_YS(app.SLM_ops, holo_pointers{rem(n_pl,num_planes)+1});      % z position changes at the end of the frame
%                 resetCounters(session);
%             end
%         end
        f_SLM_update_YS(app.SLM_ops, app.SLM_blank_pointer);
        app.InitializeimagingButton.Value = 0;
        app.ImagingReadyLamp.Color = [0.80,0.80,0.80];
        app.abort_imaging = 0;
    catch
        app.InitializeimagingButton.Value = 0;
        app.ImagingReadyLamp.Color = [0.80,0.80,0.80];
        disp('Imaging run failed')
        f_SLM_update_YS(app.SLM_ops, app.SLM_blank_pointer);
    end
end

end