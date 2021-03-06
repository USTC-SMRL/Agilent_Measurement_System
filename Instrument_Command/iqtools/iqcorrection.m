function iqresult = iqcorrection(iqdata, fs, fpoints)
% perform amplitude flatness compensation on a complex signal using the
% frequency response that has been captured previously with iqtone 
%
% usage: result = iqcorrection(iqdata, fs, fpoints);
%   iqdata - input vector
%   fs - sample rate in Hz
%   fpoints - number of frequency points for compensation (optional)
%
% Agilent Technologies, Thomas Dippon, 2011-2013
%
% Disclaimer of Warranties: THIS SOFTWARE HAS NOT COMPLETED AGILENT'S FULL
% QUALITY ASSURANCE PROGRAM AND MAY HAVE ERRORS OR DEFECTS. AGILENT MAKES 
% NO EXPRESS OR IMPLIED WARRANTY OF ANY KIND WITH RESPECT TO THE SOFTWARE,
% AND SPECIFICALLY DISCLAIMS THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
% FITNESS FOR A PARTICULAR PURPOSE.
% THIS SOFTWARE MAY ONLY BE USED IN CONJUNCTION WITH AGILENT INSTRUMENTS. 

    iqresult = iqdata;
    % make sure the data is in the correct format
    if (isvector(iqdata) && size(iqdata,1) > 1)
        iqdata = iqdata.';
    end
    % load the frequency response curve
    try
        load(iqampCorrFilename());
        freq = ampCorr(:,1);
        mag = ampCorr(:,2);
    catch e
        errordlg('Correction file not found. Please run calibration to create it.');
        return;
    end
    if (size(ampCorr,2) >= 4)   % separate correction for I (column 3) and Q (column 4)
        fdata = fftshift(fft(real(iqdata)));
        points = length(fdata);
        newFreq = linspace(-0.5, 0.5-1/points, points) * fs;
        % for operation in second Nyquist band, shift the X axis
        if (sum(ampCorr(:,1)) / length(ampCorr(:,1)) > fs/2)
            newFreq = newFreq + fs;
        end
        corrLin = interp1(ampCorr(:,1), ampCorr(:,3), newFreq, 'pchip', 1);
        iq1 = ifft(fftshift(fdata .* corrLin));
        fdata = fftshift(fft(imag(iqdata)));
        corrLin = interp1(ampCorr(:,1), ampCorr(:,4), newFreq, 'pchip', 1);
        iq2 = ifft(fftshift(fdata .* corrLin));
        iqresult = complex(real(iq1)-imag(iq2), imag(iq1)+real(iq2));
    elseif (size(ampCorr,2) >= 3)   % complex correction in column 3
        fdata = fftshift(fft(iqdata));
        points = length(fdata);
        newFreq = linspace(-0.5, 0.5-1/points, points) * fs;
        % for operation in second Nyquist band, shift the X axis
        if (sum(ampCorr(:,1)) / length(ampCorr(:,1)) > fs/2)
            newFreq = newFreq + fs;
        end
        corrLin = interp1(ampCorr(:,1), ampCorr(:,3), newFreq, 'pchip', 1);
        iqresult = ifft(fftshift(fdata .* corrLin));
    else
        % amplitude correction only --> convert into FIR filter
        if (~exist('fpoints'))
            fpoints = 128;
            ldspacing = ceil(log2(fs/fpoints / min(diff(freq))));
            % make sure the frequency interval is at least as "fine" as in the
            % amplitude correction file
            if (ldspacing > 0)
                fpoints = fpoints * 2^ldspacing;
            end
        end
        % if the frequency values are above 1st Nyquist, move them down
        if (min(freq) >= fs && max(freq) <= 3*fs/2)     % 3rd Nyquist
            freq = freq - fs;
        end
        if (min(freq) >= fs/2 && max(freq) <= fs)       % 2nd Nyquist
            freq = fs - freq;
            freq = flipud(freq);
            mag = flipud(mag);
        end
        % if the amplitude correction files consists of only positive
        % frequencies, assume the same frequency response for negative side
        if (min(freq) > 0)
            freq = [-1 * flipud(freq); freq];
            mag = [flipud(mag); mag];
        end
        % extend the freqeuncy span to +/- fs/2
        f1 = freq(1) - (0.1 * (freq(1) + fs/2));
        f2 = freq(end) + (0.1 * (fs/2 - freq(end)));
        if (f1 > -fs/2)
            freq = [-fs/2;     f1; freq;];
            mag  = [ -100; mag(1);  mag;];
        end
        if (f2 < fs/2)
            freq = [freq;       f2; fs/2];
            mag  = [mag;  mag(end); -100];
        end
        % create a vector of equally spaced frequencies and associated magnitudes
        newfreq = linspace(-fs/2, fs/2 - fs/fpoints, fpoints);
        newmag = interp1(freq, mag, newfreq, 'pchip');
        linmag = 10 .^ (newmag ./ 20);
        %... and derive a filter
        ampFilt = fftshift(ifft(fftshift(linmag)));
        % apply the filter to the signal with wrap-around to assure phase
        % continuity
        len = length(iqdata);
        nfilt = length(ampFilt);
        wrappedIQ = [iqdata(end-mod(nfilt,len)+1:end) repmat(iqdata, 1, floor(nfilt/len)+1)];
        tmp = filter(ampFilt, 1, wrappedIQ);
        iqresult = tmp(nfilt+1:end);
        scale = max(max(abs(real(iqresult))), max(abs(imag(iqresult))));
        iqresult = iqresult ./ scale;
    end
end
