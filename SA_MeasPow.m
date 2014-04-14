function [Power, Frequency] = SA_MeasPow( ip_address, port, center_frequency, varargin )
% SA_MeasPow measures power of a single-tone signal using the signal
% analyzer Agilent MXA N9020A.
% - This function measures power of signal at the input of Agilent 
% - MXA N9020A signal analyzer using TCP/IP protocol. As this function uses
% - Agilent's measurement command, the detailed defination of the
% - measurement result should be checked in Agilent's manuals for MXA N9020A 
% - signal analyzer.
% - 'ip_address' - specify the IP address of the signal analyzer.
% - 'port' - specify the port number of the signal analyzer for TCP/IP connection.
% - 'center_frequency' - specify the frequency component to be measured. As the sweep range is defined by 'center_frequency'
%                       and 'span', the real frequency must be in this range, in Hz.
% - 'referencelevel' - specify the power reference level of the signal, should be higher than the real level to avoid
%                       distortion and saturation. Default value is 10 (dBm).
% - 'span' - specify the sweep span of current display and measurement. As the sweep range is defined by 'center_frequency' and 'span', 
%           the real frequency must be in this range. Default value is 1 (KHz).
% - 'RBW' - sp  ecify the resolution bandwidth used in frequency sweep. Default value is 9.1 (Hz).
% - 'VBW' - specify the video bandwidth used in frequency sweep. Default value is 9.1 (Hz).
% - 'coupling' - specify the input coupling at the RF port of signal analyzer. Default value is 'DC' for frequency < 50 MHz,
%               and 'AC' for the rest.

centFreq = center_frequency;                                                % Center frequency of signal analyzer, in Hz.
refLevel = 10;                                                              % Reference power level of signal analyzer, in dBm.
span_initial = min(100E3, abs(centFreq) * 0.2);                             % Sweep span of signal analyzer before signal is detected, in Hz.
                                                                            % For low center frequency. additional limit is added to filter low frequency noise.
span = 1000;                                                                % Sweep span of signal analyzer, in Hz.
RBW_initial = max(span_initial / 10000 * 9.1, 1);                           % Resolution bandwidth of signal analyzer before signal is detected, in Hz, at least 1 Hz.
RBW = 9.1;                                                                  % Resolution bandwidth of signal analyzer, in Hz, at least 1 Hz.
VBW_initial = max(span_initial / 10000 * 9.1, 1);                           % Video bandwidth of signal analyzer before signal is detected, in Hz, at least 1 Hz.
VBW = 9.1;                                                                  % Video bandwidth of signal analyzer, in Hz, at least 1 Hz.
if abs(centFreq) <= 50E6                                                    % Input coupling of signal analyzer, 
    coupl = 'DC';                                                           % Please be aware that AC coupling can only guarantee  
else                                                                        % accuracy specification for frequency above 50 MHz,
    coupl = 'AC';                                                           % so the default value is 'DC' for frequency < 50 MHz 
end                                                                         % and 'AC' for the rest.

for i = 1:nargin-4
    if (ischar(varargin{i}))
        switch lower(varargin{i})
            case 'referencelevel'; refLevel = varargin{i+1};
            case 'span'; span = varargin{i+1};
            case 'rbw'; RBW = varargin{i+1};
            case 'vbw'; VBW = varargin{i+1};
            case 'coupling'; coupl = varargin(i+1);
        end
    end
end           

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



% Configure the signal analyzer using parameters given, only related settings are configured, other settings should be configured manually at the start of the whole measurement.
% Configure input/output related settings.
xfprintf(f, [':INPut:COUPling ', coupl]);                                   % Configure RF Coupling to 'coupl', only AC or DC is available.

% Configure Y axis related settings.
xfprintf(f, ':SENSe:POWer:RF:ATTenuation:AUTO ON');                         % Configure mechanical attenuator to be auto coupled
xfprintf(f, ':SENSe:POWer:RF:ATTenuation:STEP:INCRement 2 dB');             % to reference level with a step of 2 dB.
xfprintf(f, ':UNIT:POW dBm');                                               % Configure power unit to 'dBm'.
xfprintf(f, [':DISPlay:WINDow1:TRACe:Y:SCALe:RLEVel ', num2str(refLevel),' dBm']);  % Configure power reference to specified level.

% Configure X axis related settings.
xfprintf(f, [':SENSe:FREQuency:CENTer ', num2str(centFreq/1E6, '%7.6f'), ' MHz']);  % Configure center frequency to 'centFreq'. 'centFreq' is in Hz,
                                                                                    % and the command converts it to MHz. Function 'num2str' keeps the resolution 
                                                                                    % to Hz by using formatSpec '%7.6f'.
xfprintf(f, [':SENSe:FREQuency:SPAN ', num2str(span_initial/1E3, '%4.3f'), ' KHz']);  % Configure span frequency to 'span_initial'. 'span' is in Hz, and the command converts it to KHz.
                                                                                      % Function 'num2str' keeps the resolution 
                                                                                      % to Hz by using formatSpec '%4.3f'.
xfprintf(f, [':SENSe:BANDwidth:RESolution ', num2str(RBW_initial),' Hz']);  % Configure resolution bandwidth to 'RBW_initial', in Hz.
xfprintf(f, [':SENSe:BANDwidth:VIDeo ', num2str(VBW_initial),' Hz']);       % Configure video bandwidth to 'VBW_initial', in Hz.

pause(0.5);                                                                   % Pause for two seconds for the instrument to acquire and process data.


% Measure peak power in specified frequency range.
% Place a marker at the highest peak, change the center frequency to the peak's
% frequency, and keep searching the peak continuously.
xfprintf(f, ':CALCulate:MARKer1:STATe ON');
xfprintf(f, ':CALCulate:MARKer1:MODE POSition');
xfprintf(f, ':CALCulate:MARKer:PEAK:THReshold:STATe OFF');
xfprintf(f, ':CALCulate:MARKer1:MAXimum');
xfprintf(f, ':CALCulate:MARKer1:SET:CENTer');
xfprintf(f, ':CALCulate:MARKer1:CPSearch:STATe ON');
 

% Reconfigure span and RBW, VBW for accurate measurement.
xfprintf(f, [':SENSe:FREQuency:SPAN ', num2str(span/1E3, '%4.3f'), ' KHz']);  % Configure span frequency to 'span'. 'span' is in Hz, and the command converts it to KHz.
                                                                              % Function 'num2str' keeps the resolution 
                                                                              % to Hz by using formatSpec '%4.3f'.
xfprintf(f, [':SENSe:BANDwidth:RESolution ', num2str(RBW),' Hz']);          % Configure resolution bandwidth to 'RBW', in Hz.
xfprintf(f, [':SENSe:BANDwidth:VIDeo ', num2str(VBW),' Hz']);               % Configure video bandwidth to 'VBW', in Hz.

pause(2);                                                                   % Pause for two seconds for the instrument to acquire and process data.

% Flush input buffer before measurement.
flushinput(f);

% Meausre the peak's power for the first pass.
Power_onepass  = query(f, ':CALCulate:DATA1:COMPress? MAXimum');

% Optimize reference power level using power measured in the first pass,
% thus optimize mechanical attenuator.
xfprintf(f, [':DISPlay:WINDow1:TRACe:Y:SCALe:RLEVel ', num2str(round(str2double(Power_onepass) + 4)),' dBm']);  % Configure power reference to specified level.

pause(2)

% Flush input buffer before measurement.
flushinput(f);

% Meausre the peak's power for the second and final pass.
Power_secondpass  = query(f, ':CALCulate:DATA1:COMPress? MAXimum');
Frequency_secondpass = query(f, ':CALCulate:MARKer1:X?');

Power = str2double(Power_secondpass);
Frequency = str2double(Frequency_secondpass);

fclose(f);
end
