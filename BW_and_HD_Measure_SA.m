addpath(genpath('../'));
%IP.M8190A = '';
SA.ip_address = '192.168.1.130';
SA.port = 5025;
M8190A_fs = 6E9;
Scope.ip_address = '192.168.1.120';
Scope.port = 5025;

% Data.signal_frequency_desired = (([1:1:9, 10:10:90, 100:20:500])*1E6)';
Data.signal_frequency_desired = ((200:5:500)*1E6)';

for i = 1:1:size(Data.signal_frequency_desired, 1) 
    disp(num2str(Data.signal_frequency_desired(i, 1)));
    % Download waveform with current frequency.
    M8190Aout(M8190A_fs, Data.signal_frequency_desired(i, 1));
    pause(0.5);
    
    % Measure input and output signal power and frequency.
    [Data.signal_power(i, 1),Data.signal_frequency_measured(i, 1)] = SA_MeasPow( SA.ip_address ,SA.port , Data.signal_frequency_desired(i, 1));
    Data.second_harmonic_frequency_calculated(i, 1) = 2 * Data.signal_frequency_measured(i, 1);
    Data.third_harmonic_frequency_calculated(i, 1) = 3 * Data.signal_frequency_measured(i, 1);
    [Data.input_voltage(i, 1), ~ , ~ , ~] = Scope_MeasVAmp(Scope.ip_address, Scope.port);
    [Data.input_frequency(i, 1), ~ , ~ , ~] = Scope_MeasFreq(Scope.ip_address, Scope.port);
    pause(0.5);
    
    % Measure output harmonic power and frequency.
    disp([num2str(Data.signal_frequency_desired(i, 1)), ' second harmonic']);
    [Data.second_harmonic_power(i, 1),Data.second_harmonic_frequency_measured(i, 1)] = SA_MeasPow( SA.ip_address, SA.port, Data.second_harmonic_frequency_calculated(i, 1), 'referencelevel', -40);
    disp([num2str(Data.signal_frequency_desired(i, 1)), ' third harmonic']);
    [Data.third_harmonic_power(i, 1),Data.third_harmonic_frequency_measured(i, 1)] = SA_MeasPow( SA.ip_address, SA.port, Data.third_harmonic_frequency_calculated(i, 1), 'referencelevel', -40);
end

% Define headers and format of data file.
LongName = 'Input Frequency, Input Voltage, Signal Frequency, Signal Frequency, Signal Power, 2nd Harmonic Frequency, 2nd Harmonic Frequency, 2nd Harmonic Power, 3rd Harmonic Frequency, 3rd Harmonic Frequency, 3rd Harmonic Power\n';
Unit = 'Hz, V, Hz, Hz, dBm, Hz, Hz, dBm, Hz, Hz, dBm\n';
Comment = 'Measured by Scope,Measured by Scope, Desired, Measured, Measured, Calculated, Measured, Measured, Calculated, Measured, Measured\n';
formatSpec = '%7.0f, %5.4f, %7.0f, %7.0f, %3.2f, %7.0f, %7.0f, %3.2f, %7.0f, %7.0f, %3.2f\n';

% Check directory and file existence and create them.
if ~isdir('data')
    mkdir('data');
end
filename = ['./data/', strcat(num2str(fix(clock), '%04d%02d%02d_%02d-%02d-%02d')), '.csv'];  % Filename is based on system clock.
fileID = fopen(filename, 'w');

% Write data to file with headers.
fprintf(fileID, LongName);
fprintf(fileID, Unit);
fprintf(fileID, Comment);
for row = 1:1:size(Data.signal_frequency_desired, 1)
    fprintf(fileID, formatSpec, Data.input_frequency(row, 1), Data.input_voltage(row, 1), ...
            Data.signal_frequency_desired(row, 1), Data.signal_frequency_measured(row, 1), Data.signal_power(row, 1), ...
            Data.second_harmonic_frequency_calculated(row, 1), Data.second_harmonic_frequency_measured(row, 1), Data.second_harmonic_power(row, 1), ...
            Data.third_harmonic_frequency_calculated(row, 1), Data.third_harmonic_frequency_measured(row, 1), Data.third_harmonic_power(row, 1));
end

fclose(fileID);