function f_sg_initialize_DAQ(app)

%daq_list = daqvendorlist();

try
    app.InitializeDAQLamp.Color = [0.8 0.8 0.8];
    app.DAQ_session = daq.createSession('ni');
    %app.DAQ_session = daq('ni');
    
    chan_made = false(3);

    % Setup counter
    try
        counter_id = sprintf('ctr%d', app.DAQcounterchannelEditField.Value);
        app.DAQ_session.addCounterInputChannel(app.NIDAQdeviceEditField.Value, counter_id, 'EdgeCount');
        resetCounters(app.DAQ_session);
        chan_made(1) = 1;
    catch
        fprintf('DAQ: No %s channel in %s available\n', counter_id, app.NIDAQdeviceEditField.Value)
    end

    % setup AI
    try
        ai_id = sprintf('ai%d', app.DAQAIchannelEditField.Value);
        app.DAQ_session.addAnalogInputChannel(app.NIDAQdeviceEditField.Value,ai_id,'Voltage');

        % make the data acquisition 'SingleEnded, to separate the '
        daq_ai_chan = false(length(app.DAQ_session.Channels),1);
        for nchan = 1:length(app.DAQ_session.Channels)
            if strcmpi(app.DAQ_session.Channels(nchan).ID(1:2), 'ai')
                app.DAQ_session.Channels(nchan).TerminalConfig = 'SingleEnded';
                app.DAQ_session.Channels(nchan).Range = [-10 10];
                daq_ai_chan(nchan) = 1;
            end
        end
        app.DAQ_ai_chan = find(daq_ai_chan);
        chan_made(2) = 1;
    catch
        fprintf('DAQ: No %s channel in %s available\n', ai_id, app.NIDAQdeviceEditField.Value)
    end

    % setup frame trigger
    try
        ao_id = sprintf('ao%d', app.DAQAOchannelEditField.Value);
        app.DAQ_session.addAnalogOutputChannel(app.NIDAQdeviceEditField.Value, ao_id, 'Voltage');
        chan_made(3) = 1;
    catch
        fprintf('DAQ: No %s channel in %s available\n', ao_id, app.NIDAQdeviceEditField.Value)
    end
    
    if sum(chan_made)
        app.InitializeDAQLamp.Color = [0 1 0];
    else
        app.InitializeDAQLamp.Color = [0.8 0.8 0.8];
        fprintf('Warning: DAQ initialized, but no channels set up\n');
    end
catch
    app.InitializeDAQLamp.Color = [0.8 0.8 0.8];
    fprintf('Warning: DAQ not initialized, check connections and DAQ params\n');
end

end