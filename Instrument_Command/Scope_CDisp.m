function result = Scope_CDisp(ip_address, port)
%Scope_CDisp send a "Clear Display" command to the oscilloscope.
% - This function sends a ":CDISplay" command using TCP/IP protocol to the
% - oscilloscope at ip_address:port to clear current display and 
% - measurement results on the scope's screen.
% - 'ip_address' - specify the IP address of the scope.
% - 'port' - specify the port number of the scope for TCP/IP connection.

result = 0;
try
    f = tcpip(ip_address, port);
catch e
    errordlg({'Error calling tcpip(). Please verify that' ...
            'you have the "Instrument Control Toolbox" installed' ...
            'MATLAB error message:' e.message}, 'Error');
    f = [];
    result = 1;
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
        result = 1;
    end
end;

%disp(query(f, '*IDN?'));

result = xfprintf(f, ':CDISplay');

fclose(f);

end
