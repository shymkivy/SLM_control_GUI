function f_SLM_AO_scan_zernike2(app)

% generate coordinates
SLMn = app.SLM_ops.width;
SLMm = app.SLM_ops.height;
beam_width = app.BeamdiameterpixEditField.Value;
xlm = linspace(-SLMm/beam_width, SLMm/beam_width, SLMm);
xln = linspace(-SLMn/beam_width, SLMn/beam_width, SLMn);
[fX, fY] = meshgrid(xln, xlm);
[theta, rho] = cart2pol( fX, fY );

zernike_data = app.ZernikeListTable.Data;

num_modes = size(zernike_data,1);

all_modes = zeros(SLMm, SLMn, num_modes);

% generate all polynomials
for n_mode = 1:num_modes
    Z_nm = f_SLM_zernike_pol(rho, theta, zernike_data(n_mode,2), zernike_data(n_mode,3));
    all_modes(:,:,n_mode) = Z_nm;
end

% now scan
% GUI will send a trigger into Prairie to initiate every scan. GUI will
% will either wait certain time or read out frame outputs to find out when
% scan is over.

mode_weights = cell(num_modes,1);
if strcmp(app.SLMrefreshconditionSwitch.Value,'EoF trigger')
    eof_trigger = 1;
    resetCounters(app.DAQ_session);
    scan_frame = inputSingleScan(app.DAQ_session);
else
    eof_trigger = 0;
    delay = app.DelaysecEditField.Value;
end

try
    
    % generate pointers
    holo_pointers = cell(num_planes,1);
    for n_mode = 1:num_modes
        mode_weights{n_mode} = zernike_data(n_mode,4):zernike_data(n_mode,5):zernike_data(n_mode,6);
        for n_weight = 1:numel(mode_weights{n_mode})
            f_SLM_convert_to_pointer(app, all_modes(:,:,n_mode)*mode_weights{n_mode}(n_weight));
        end
    end
    
    app.ZernikeReadyLamp.Color = [0.00,1.00,0.00];
    pause(0.05);
    %frame_start_times = zeros(num_planes_all,1);
    SLM_frame = 0;
    tic;
    
    for n_mode = 1:num_modes
        mode_weights{n_mode} = zernike_data(n_mode,4):zernike_data(n_mode,5):zernike_data(n_mode,6);

        for n_weight = 1:numel(mode_weights{n_mode})
            % upload pattern
            SLM_frame = SLM_frame + 1;
            app.SLM_Image_pointer.Value = f_SLM_convert_to_pointer(app, all_modes(:,:,n_mode)*mode_weights{n_mode}(n_weight));
            f_SLM_update_YS(app.SLM_ops, app.SLM_Image_pointer);
            pause(0.005);
            %frame_start_times(SLM_frame) = toc;
            
            % send trigger
            try
                app.DAQ_session.outputSingleScan(3);
                pause(0.001);
                app.DAQ_session.outputSingleScan(0);
            catch
                fprintf('Warning: DAQ is not workimg\n');
            end
            % receive trigger
            if eof_trigger
                % wait for EoF trigger
                while scan_frame<SLM_frame
                    scan_frame = inputSingleScan(app.DAQ_session);
                    pause(0.005);
                end
            else
                pause(delay);
            end
        end
    end
    
    if eof_trigger
        resetCounters(app.DAQ_session);
    end
    app.ScanZernikeButton.Value = 0;
    app.ZernikeReadyLamp.Color = [0.80,0.80,0.80];
    f_SLM_update_YS(app.SLM_ops, app.SLM_blank_pointer);
catch
    disp('Zernike Scan failed');
    app.ScanZernikeButton.Value = 0;
    app.ZernikeReadyLamp.Color = [0.80,0.80,0.80];
    pause(0.05);
    f_SLM_update_YS(app.SLM_ops, app.SLM_blank_pointer);
end

end