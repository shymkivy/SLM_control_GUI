function f_SLM_initialize_DAQ(app)

try
    app.InitializeDAQLamp.Color = [0.8 0.8 0.8];
    app.DAQ_session = daq.createSession('ni');
    % Setup counter
    counter_id = sprintf('ctr%d', app.DAQcounterchannelEditField.Value);
    app.DAQ_session.addCounterInputChannel(app.NIDAQdeviceEditField.Value, counter_id, 'EdgeCount');
    resetCounters(app.DAQ_session);
    
    % setup AI
    ai_id = sprintf('ai%d', app.DAQAIchannelEditField.Value);
    app.DAQ_session.addAnalogInputChannel(app.NIDAQdeviceEditField.Value,ai_id,'Voltage');
    
    % make the data acquisition 'SingleEnded, to separate the '
%     for nchan = 1:length(channels)
%         if channels(nchan) <= 3 %strcmp(s.Channels(ii).ID, 'ai3')
%             s.Channels(nchan).TerminalConfig = 'SingleEnded';
%             s.Channels(nchan).Range = [-10 10];
%         end
%     end
    
    % setup frame trigger
    app.InitializeDAQLamp.Color = [0 1 0];
catch
    fprintf('Warning: DAQ not initialized, check connections and DAQ params\n');
end

end