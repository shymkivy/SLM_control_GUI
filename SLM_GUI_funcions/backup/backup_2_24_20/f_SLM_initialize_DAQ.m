function f_SLM_initialize_DAQ(app)

try
    app.InitializeDAQLamp.Color = [0.8 0.8 0.8];
    app.DAQ_session = daq.createSession ('ni');
    % Setup counter
    counter_id = sprintf('ctr%d', app.DAQcounterchannelEditField.Value);
    app.DAQ_session.addCounterInputChannel(app.NIDAQdeviceEditField.Value, counter_id, 'EdgeCount');
    resetCounters(app.DAQ_session);
    % setup frame trigger
    frame_trig_id = sprintf('ao%d', app.DAQAOchannelforTRIGEditField.Value);
    app.DAQ_session.addAnalogOutputChannel(app.NIDAQdeviceEditField.Value, frame_trig_id,'Voltage');
    app.InitializeDAQLamp.Color = [0 1 0];
catch
    fprintf('Warning: DAQ not initialized, check connections and DAQ params\n');
end

end