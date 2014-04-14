Scope.ip_address = '192.168.1.120';
Scope.port = 5025;
SA.ip_address = '192.168.1.130';
SA.port = 5025;

Fs = 12E9;

T = [1/Fs:1/Fs:10E-6];
FreqSet = [1:3:575] * 1E6;

VoltRead = zeros(size(FreqSet, 2), 4);
FreqRead = zeros(size(FreqSet, 2), 4);

for ii = 1:size(FreqSet, 2);
    disp(FreqSet(1, ii));
    SignData = exp(1i*2*pi*FreqSet(1, ii)*T);
    iqdownload(SignData, Fs);
    pause(2);
    Scope_CDisp(Scope.ip_address, Scope.port);
    pause(4);
    fprintf('Begin measurement of Frequency %d\n', ii);
    VoltRead(ii, 1:4) = Scope_MeasVAmp(Scope.ip_address, Scope.port);
    FreqRead(ii, 1:4) = Scope_MeasFreq(Scope.ip_address, Scope.port);
end

