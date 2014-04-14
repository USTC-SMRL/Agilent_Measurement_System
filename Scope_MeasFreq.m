function [freq1, freq2, freq3, freq4] = Scope_MeasFreq(ip_address, port)
% Scope_MeasFreq measures frequency of signal applied to each four channel of the oscilloscope.
% - This function measures frequency of signal at each channel of the
% - oscilloscope using TCP/IP protocol. As the oscilloscpe has four
% - channels, the return result of this function is a four-element row
% - vector, and the N'th element represents frequency measured of channel
% - N. As this function uses Agilent's measurement command, the detailed
% - defination of the measurement result should be checked in Agilent's
% - manuals for DSO-X 92004Q oscilloscope.
% - "ip_address" - specify the IP address of the scope.
% - "port" - specify the port number of the scope for TCP/IP connection.


% Connect the TCPIP object to the host.
try
    f = tcpip(ip_address, port);
catch e
    errordlg({'Error calling tcpip(). Please verify that' ...
            'you have the "Instrument Control Toolbox" installed' ...
            'MATLAB error message:' e.message}, 'Error');
    f = [];
end

if (~isempty(f) && strcmp(f.Status, 'closed'))
    f.OutputBufferSize = 2000;
    f.InputBufferSize = 6400;
    f.Timeout = 20;
    try
        fopen(f);
    catch e
        errordlg({'Could not open connection to ' addr ...
            'Please verify that you specified the correct address' ...
            'in the "Configure Instrument Connection" dialog.' ...
            'Verify that you can communicate with the' ...
            'instrument using the Agilent Connection Expert'}, 'Error');
        f = [];
    end
end;

%disp(query(f, '*IDN?'));

% Flush input buffer before measurement.
flushinput(f);

freq1 = str2double(query(f, ':MEASure:FREQuency? CHANnel1'));
freq2 = str2double(query(f, ':MEASure:FREQuency? CHANnel2'));
freq3 = str2double(query(f, ':MEASure:FREQuency? CHANnel3'));
freq4 = str2double(query(f, ':MEASure:FREQuency? CHANnel4'));

fclose(f);

end

