function varargout = iqconfig(varargin)
% IQCONFIG M-file for iqconfig.fig
%      IQCONFIG, by itself, creates a new IQCONFIG or raises the existing
%      singleton*.
%
%      H = IQCONFIG returns the handle to a new IQCONFIG or the handle to
%      the existing singleton*.
%
%      IQCONFIG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IQCONFIG.M with the given input arguments.
%
%      IQCONFIG('Property','Value',...) creates a new IQCONFIG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before iqconfig_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to iqconfig_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help iqconfig

% Last Modified by GUIDE v2.5 03-Feb-2014 22:59:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @iqconfig_OpeningFcn, ...
                   'gui_OutputFcn',  @iqconfig_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before iqconfig is made visible.
function iqconfig_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to iqconfig (see VARARGIN)

% Choose default command line output for iqconfig
handles.output = hObject;
set(handles.popupmenuModel, 'Value', 1);    % if nothing found, choose M8190A_14bit
set(handles.popupmenuConnectionType, 'Value', 2);

% Update handles structure
guidata(hObject, handles);

try
    arbCfgFile = iqarbConfigFilename();
catch
    arbCfgFile = 'arbConfig.mat';
end
try
    load(arbCfgFile);
catch e
    % missing arbConfig file is not an error
end
try
    if (exist('arbConfig', 'var'))
        if (isfield(arbConfig, 'model'))
            arbModels = get(handles.popupmenuModel, 'String');
            if (exist('iqdownload_AWG7xxx.m', 'file'))
                arbModels{end+1} = 'AWG7xxx';
                set(handles.popupmenuModel, 'String', arbModels);
            end
            if (exist('iqdownload_AWG7xxxx.m', 'file'))
                arbModels{end+1} = 'AWG7xxxx';
                set(handles.popupmenuModel, 'String', arbModels);
            end
            if (exist('iqdownload_M8195A_Rev0.m', 'file') || exist('iqdownload_M8195A_Rev0.p', 'file'))
                arbModels(2:end+1) = arbModels(1:end);
                arbModels{1} = 'M8195A_Rev0';
                set(handles.popupmenuModel, 'String', arbModels);
            end
            idx = find(strcmp(arbModels, arbConfig.model));
            if (isempty(idx) && strcmp(arbConfig.model, 'M8190A'))
                idx = 2;  % special case: M8190A turns into M8190A_14bit
            end
            if (idx > 0)
                set(handles.popupmenuModel, 'Value', idx);
            end
        end
        if (isfield(arbConfig, 'connectionType'))
            connTypes = get(handles.popupmenuConnectionType, 'String');
            idx = find(strcmp(connTypes, arbConfig.connectionType));
            if (idx > 0)
                set(handles.popupmenuConnectionType, 'Value', idx);
            end
            popupmenuConnectionType_Callback([], [], handles);
        end
        if (isfield(arbConfig, 'visaAddr'))
            set(handles.editVisaAddr, 'String', arbConfig.visaAddr);
        end
        if (isfield(arbConfig, 'ip_address'))
            set(handles.editIPAddress, 'String', arbConfig.ip_address);
        end
        if (isfield(arbConfig, 'port'))
            set(handles.editPort, 'String', num2str(arbConfig.port));
        end
        if (isfield(arbConfig, 'skew'))
            set(handles.editSkew, 'String', num2str(arbConfig.skew));
            set(handles.editSkew, 'Enable', 'on');
            set(handles.checkboxSetSkew, 'Value', 1);
        else
            set(handles.editSkew, 'Enable', 'off');
            set(handles.checkboxSetSkew, 'Value', 0);
        end
        if (isfield(arbConfig, 'gainCorrection'))
            set(handles.editGainCorr, 'String', num2str(arbConfig.gainCorrection));
            set(handles.editGainCorr, 'Enable', 'on');
            set(handles.checkboxSetGainCorr, 'Value', 1);
        else
            set(handles.editGainCorr, 'Enable', 'off');
            set(handles.checkboxSetGainCorr, 'Value', 0);
        end
        s = 1;  % use continuous as default
        if (isfield(arbConfig, 'triggerMode'))
            s = find(strcmp(get(handles.popupmenuTrigger, 'String'), arbConfig.triggerMode));
            if (s == 0)
                s = 1;
            end
        end
        set(handles.popupmenuTrigger, 'Value', s);
        if (isfield(arbConfig, 'amplitude'))
            set(handles.editAmpl1, 'String', num2str(arbConfig.amplitude(1)));
            set(handles.editAmpl1, 'Enable', 'on');
            set(handles.editAmpl2, 'String', num2str(arbConfig.amplitude(2)));
            set(handles.editAmpl2, 'Enable', 'on');
            set(handles.checkboxSetAmpl, 'Value', 1);
        else
            set(handles.editAmpl1, 'Enable', 'off');
            set(handles.editAmpl2, 'Enable', 'off');
            set(handles.checkboxSetAmpl, 'Value', 0);
        end
        if (isfield(arbConfig, 'offset'))
            set(handles.editOffs1, 'String', num2str(arbConfig.offset(1)));
            set(handles.editOffs1, 'Enable', 'on');
            set(handles.editOffs2, 'String', num2str(arbConfig.offset(2)));
            set(handles.editOffs2, 'Enable', 'on');
            set(handles.checkboxSetOffs, 'Value', 1);
        else
            set(handles.editOffs1, 'Enable', 'off');
            set(handles.editOffs2, 'Enable', 'off');
            set(handles.checkboxSetOffs, 'Value', 0);
        end
        if (isfield(arbConfig, 'ampType'))
            ampTypes = get(handles.popupmenuAmpType, 'String');
            idx = find(strcmp(ampTypes, arbConfig.ampType));
            if (idx > 0)
                set(handles.popupmenuAmpType, 'Value', idx);
            end
            set(handles.checkboxSetAmpType, 'Value', 1);
            set(handles.popupmenuAmpType, 'Enable', 'on');
        else
            set(handles.checkboxSetAmpType, 'Value', 0);
        end
        set(handles.checkboxExtClk, 'Value', (isfield(arbConfig, 'extClk') && arbConfig.extClk));
        set(handles.checkboxRST, 'Value', (isfield(arbConfig, 'do_rst') && arbConfig.do_rst));
        set(handles.checkboxInterleaving, 'Value', (isfield(arbConfig, 'interleaving') && arbConfig.interleaving));
        if (isfield(arbConfig, 'defaultFc'))
            set(handles.editDefaultFc, 'String', sprintf('%g', arbConfig.defaultFc));
        end
        tooltips = 1;
        if (isfield(arbConfig, 'tooltips') && arbConfig.tooltips == 0)
            tooltips = 0;
        end
        set(handles.checkboxTooltips, 'Value', tooltips);
        if (isfield(arbConfig, 'amplitudeScaling'))
            set(handles.editAmplScale, 'String', sprintf('%g', arbConfig.amplitudeScaling));
        end
        if (isfield(arbConfig, 'carrierFrequency'))
            set(handles.editCarrierFreq, 'String', sprintf('%g', arbConfig.carrierFrequency));
            set(handles.checkboxSetCarrierFreq, 'Value', 1);
        else
            set(handles.textCarrierFreq, 'Enable', 'off');
            set(handles.editCarrierFreq, 'Enable', 'off');
            set(handles.checkboxSetCarrierFreq, 'Value', 0);
        end
        popupmenuModel_Callback([], [], handles);
        if (isfield(arbConfig, 'visaAddr2'))
            set(handles.checkboxVisaAddr2, 'Value', 1);
            set(handles.editVisaAddr2, 'String', arbConfig.visaAddr2);
            set(handles.editVisaAddr2, 'Enable', 'on');
            set(handles.pushbuttonTestAWG2, 'Enable', 'on');
            set(handles.pushbuttonSwapAWG, 'Enable', 'on');
        else
            set(handles.checkboxVisaAddr2, 'Value', 0);
            set(handles.editVisaAddr2, 'Enable', 'off');
            set(handles.pushbuttonTestAWG2, 'Enable', 'off');
            set(handles.pushbuttonSwapAWG, 'Enable', 'off');
        end
        if (isfield(arbConfig, 'useM8192A') && (arbConfig.useM8192A ~= 0))
            set(handles.checkboxVisaAddrM8192A, 'Value', 1);
            set(handles.editVisaAddrM8192A, 'Enable', 'on');
            set(handles.pushbuttonTestM8192A, 'Enable', 'on');
        else
            set(handles.checkboxVisaAddrM8192A, 'Value', 0);
            set(handles.editVisaAddrM8192A, 'Enable', 'off');
            set(handles.pushbuttonTestM8192A, 'Enable', 'off');
        end
        if (isfield(arbConfig, 'visaAddrM8192A'))
            set(handles.editVisaAddrM8192A, 'String', arbConfig.visaAddrM8192A);
        end
        if (isfield(arbConfig, 'visaAddrScope'))
            set(handles.checkboxVisaAddrScope, 'Value', 1);
            set(handles.editVisaAddrScope, 'String', arbConfig.visaAddrScope);
            set(handles.editVisaAddrScope, 'Enable', 'on');
            set(handles.pushbuttonTestScope, 'Enable', 'on');
        else
            set(handles.checkboxVisaAddrScope, 'Value', 0);
            set(handles.editVisaAddrScope, 'Enable', 'off');
            set(handles.pushbuttonTestScope, 'Enable', 'off');
        end
        guidata(hObject, handles);
    end
    % spectrum analyzer
    if (exist('saConfig', 'var'))
        if (isfield(saConfig, 'connected'))
            set(handles.checkboxSAattached, 'Value', saConfig.connected);
        end
        checkboxSAattached_Callback([], [], handles);
        if (isfield(saConfig, 'visaAddr'))
            set(handles.editVisaAddrSA, 'String', saConfig.visaAddr);
        end
        if (isfield(saConfig, 'useListSweep') && saConfig.useListSweep ~= 0)
            set(handles.popupmenuSAAlgorithm, 'Value', 3);
        elseif (isfield(saConfig, 'useMarker') && saConfig.useMarker ~= 0)
            set(handles.popupmenuSAAlgorithm, 'Value', 2);
        else
            set(handles.popupmenuSAAlgorithm, 'Value', 1);
        end
    end
catch e
    errordlg(e.message);
end

if (~exist('arbConfig', 'var') || ~isfield(arbConfig, 'tooltips') || arbConfig.tooltips == 1)
set(handles.popupmenuModel, 'TooltipString', sprintf([ ...
    'Select the instrument model. For M8190A, you have to select in which\n', ...
    'mode the AWG will operate because the maximum sample rate and segment\n', ...
    'granularity are different for each mode. The "DUC" (digital upconversion)\n' ...
    'modes require a separate software license']));
set(handles.popupmenuConnectionType, 'TooltipString', sprintf([ ...
    'Use ''visa'' for connections through the VISA library.\n'...
    'Use ''tcpip'' for direct socket connections.\n' ...
    'For the 81180A ''tcpip'' is recommended. For the M8190A,\n' ...
    'a ''visa'' connection using the hislip protocol is recommended']));
set(handles.editVisaAddr, 'TooltipString', sprintf([ ...
    'Enter the VISA address as given in the Agilent Connection Expert.\n' ...
    'Examples:  TCPIP0::134.40.175.228::inst0::INSTR\n' ...
    '           TCPIP0::localhost::hislip0::INSTR\n' ...
    '           GPIB0::18::INSTR\n' ...
    'Note, that the M8190A can ONLY be connected through TCPIP.\n' ...
    'Do NOT attempt to connect via the PXIxx:x:x address.']));
set(handles.editIPAddress, 'TooltipString', sprintf([ ...
    'Enter the numeric IP address or hostname. For connection to the same\n' ...
    'PC, use ''localhost'' or 127.0.0.1']));
set(handles.editPort, 'TooltipString', sprintf([ ...
    'Specify the IP Port number for tcpip connection. Usually this is 5025.']));
set(handles.checkboxSetSkew, 'TooltipString', sprintf([ ...
    'Check this box if you want the script to set the skew between I and Q\n' ...
    '(i.e. channel 1 and channel 2). If unchecked, the skew will remain unchanged.\n' ...
    'In case of the M8195A, the skew is used to delay the I waveform mathematically.']));
set(handles.editSkew, 'TooltipString', sprintf([ ...
    'Enter the skew between I and Q (i.e. channel 1 and 2) in units of seconds.\n' ...
    'Positive values will delay ch1 vs. ch2, negative values do the opposite.\n' ...
    'Changes in the hardware will be made upon the next download of a waveform.']));
set(handles.checkboxSetGainCorr, 'TooltipString', sprintf([ ...
    'Check this box if you want the script to apply gain correction between I and Q\n' ...
    '(i.e. channel 1 and channel 2). If unchecked, the waveforms will remain unchanged.\n' ...
    'In case of the M8195A, the gain correction is used to modify the I waveform mathematically.']));
set(handles.editGainCorr, 'TooltipString', sprintf([ ...
    'Enter the gain correction between I and Q in units of dB.\n' ...
    'Positive values will boost ch1 vs. ch2, negative values do the opposite.\n' ...
    'Changes in the hardware will be made upon the next download of a waveform.']));
set(handles.checkboxSetAmpl, 'TooltipString', sprintf([ ...
    'Check this box if you want the script to set the amplitude.\n' ...
    'If unchecked, the previously configured amplitude will remain unchanged']));
set(handles.editAmpl1, 'TooltipString', sprintf([ ...
    'Enter the amplitude for channel 1 (or I) in Volts.' ...
    'Changes in the hardware will be made upon the next download of a waveform.']));
set(handles.editAmpl2, 'TooltipString', sprintf([ ...
    'Enter the amplitude for channel 2 (or Q) in Volts.' ...
    'Changes in the hardware will be made upon the next download of a waveform.']));
set(handles.checkboxSetOffs, 'TooltipString', sprintf([ ...
    'Check this box if you want the script to set the common mode offset.\n' ...
    'If unchecked, the previously configured offset will remain unchanged']));
set(handles.editOffs1, 'TooltipString', sprintf([ ...
    'Enter the common mode offset for channel 1 (or I) in Volts.' ...
    'Changes in the hardware will be made upon the next download of a waveform.']));
set(handles.editOffs2, 'TooltipString', sprintf([ ...
    'Enter the common mode offset for channel 2 (or Q) in Volts.' ...
    'Changes in the hardware will be made upon the next download of a waveform.']));
set(handles.checkboxSetAmpType, 'TooltipString', sprintf([ ...
    'Check this box if you want the script to set the amplifier type.' ...
    'If unchecked, the previously configured amplifier type will remain unchanged.']));
set(handles.popupmenuAmpType, 'TooltipString', sprintf([ ...
    'Select the type of output amplifier you want to use. ''DAC'' is the direct output\n'...
    'from the DAC, which typically has the best signal performance, but limited\n' ...
    'amplitude/offset range. Note, that only some AWGs have switchable amplifiers:\n' ...
    '81180A, M8190A_12bit and M8190A_14bit']));
set(handles.checkboxExtClk, 'TooltipString', sprintf([ ...
    'Check this box if you want to use the external sample clock input of the AWG.\n' ...
    'Make sure that you have connected a clock signal to the external input before\n' ...
    'turning this function on. Also, make sure that you specify the external clock\n' ...
    'frequency in the ''sample rate'' field of the waveform utilities.\n' ...
    'Changes in the hardware will be made upon the next download of a waveform.']));
set(handles.checkboxRST, 'TooltipString', sprintf([ ...
    'Check this box if you want to reset the AWG prior to downloading a new waveform.']));
set(handles.checkboxSAattached, 'TooltipString', sprintf([ ...
    'Check this box if you have a spectrum analyzer (PSA, MXA, PXA) connected\n' ...
    'and would like to use it for amplitude flatness correction']));
set(handles.editVisaAddrSA, 'TooltipString', sprintf([ ...
    'Enter the VISA address of the SA as given in the Agilent Connection Expert.\n' ...
    'Examples:  TCPIP0::134.40.175.228::inst0::INSTR\n' ...
    '           GPIB0::18::INSTR']));
set(handles.popupmenuSAAlgorithm, 'TooltipString', sprintf([ ...
    'Select the algorithm to use for amplitude correction on the SA.\n'...
    '''Zero span'' is the preferred method. It works reliable and is\n' ...
    'the most accurate. ''List sweep'' is only possible with MXA and PXA.\n' ...
    'It works a little faster than zero span, but is not as accurate.\n' ...
    '''Marker'' only works reliable if the resolution BW on the SA is set\n' ...
    'wide enough. It is not recommended in the general case.']));
set(handles.checkboxTooltips, 'TooltipString', sprintf([ ...
    'Enable/disable tooltips throughout the ''iqtools''.']));
set(handles.editDefaultFc, 'TooltipString', sprintf([ ...
    'If you are using the AWG with external upconversion, enter the\n' ...
    'LO frequency here. This value will be used in the multi-tone and\n' ...
    'digital modulation scripts to set the default center frequency.']));
set(handles.editAmplScale, 'TooltipString', sprintf([ ...
    'Set this to 1 to use the DAC to full scale. Values less than 1\n' ...
    'cause the waveform to be scaled to the given ratio and use less\n' ...
    'than the full scale DAC.']));
set(handles.checkboxInterleaving, 'TooltipString', sprintf([ ...
    'Check this checkbox to distribute even and odd samples to both\n' ...
    'channels. This can be used to virtually double the sample rate\n' ...
    'of the AWG. You have to manually adjust the delay of channel 2\n' ...
    'to one half of a sample period.']));
end

% UIWAIT makes iqconfig wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = iqconfig_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function editIPAddress_Callback(hObject, eventdata, handles)
% hObject    handle to editIPAddress (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editIPAddress as text
%        str2double(get(hObject,'String')) returns contents of editIPAddress as a double


% --- Executes during object creation, after setting all properties.
function editIPAddress_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editIPAddress (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editPort_Callback(hObject, eventdata, handles)
% hObject    handle to editPort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPort as text
%        str2double(get(hObject,'String')) returns contents of editPort as a double


% --- Executes during object creation, after setting all properties.
function editPort_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSkew_Callback(hObject, eventdata, handles)
% hObject    handle to editSkew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSkew as text
%        str2double(get(hObject,'String')) returns contents of editSkew as a double
paramChangedNote(handles);


% --- Executes during object creation, after setting all properties.
function editSkew_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSkew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editAmpl1_Callback(hObject, eventdata, handles)
% hObject    handle to editAmpl1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editAmpl1 as text
%        str2double(get(hObject,'String')) returns contents of editAmpl1 as a double
paramChangedNote(handles);


% --- Executes during object creation, after setting all properties.
function editAmpl1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editAmpl1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editAmpl2_Callback(hObject, eventdata, handles)
% hObject    handle to editAmpl2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editAmpl2 as text
%        str2double(get(hObject,'String')) returns contents of editAmpl2 as a double
paramChangedNote(handles);


% --- Executes during object creation, after setting all properties.
function editAmpl2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editAmpl2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function editOffs1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editOffs1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuConnectionType.
function popupmenuConnectionType_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuConnectionType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuConnectionType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuConnectionType
connTypes = cellstr(get(handles.popupmenuConnectionType, 'String'));
connType = connTypes{get(handles.popupmenuConnectionType, 'Value')};
set(handles.pushbuttonTestAWG1, 'Background', [.9 .9 .9]);
switch (connType)
    case 'tcpip'
        set(handles.editVisaAddr, 'Enable', 'off');
        set(handles.editIPAddress, 'Enable', 'on');
        set(handles.editPort, 'Enable', 'on');
    case 'visa'
        set(handles.editVisaAddr, 'Enable', 'on');
        set(handles.editIPAddress, 'Enable', 'off');
        set(handles.editPort, 'Enable', 'off');
end


% --- Executes during object creation, after setting all properties.
function popupmenuConnectionType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuConnectionType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxSetSkew.
function checkboxSetSkew_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxSetSkew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxSetSkew
val = get(hObject,'Value');
onoff = {'off' 'on'};
set(handles.editSkew, 'Enable', onoff{val+1});
paramChangedNote(handles);


% --- Executes on button press in checkboxSetAmpl.
function checkboxSetAmpl_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxSetAmpl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxSetAmpl
val = get(hObject,'Value');
onoff = {'off' 'on'};
set(handles.editAmpl1, 'Enable', onoff{val+1});
set(handles.editAmpl2, 'Enable', onoff{val+1});
paramChangedNote(handles);


% --- Executes on button press in checkboxSetAmpType.
function checkboxSetAmpType_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxSetAmpType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxSetAmpType
val = get(hObject,'Value');
onoff = {'off' 'on'};
set(handles.popupmenuAmpType, 'Enable', onoff{val+1});
paramChangedNote(handles);


% --- Executes on button press in pushbuttonSave.
function pushbuttonSave_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
checkVisaAddr(handles);
saveConfig(handles);
close(handles.output);


% --- Executes on selection change in popupmenuAmpType.
function popupmenuAmpType_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuAmpType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuAmpType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuAmpType
paramChangedNote(handles);


% --- Executes during object creation, after setting all properties.
function popupmenuAmpType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuAmpType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function saveConfig(handles)
[arbConfig saConfig] = makeArbConfig(handles);
try
    arbCfgFile = iqarbConfigFilename();
catch
    arbCfgFile = 'arbConfig.mat';
end
save(arbCfgFile, 'arbConfig', 'saConfig');
notifyIQToolWindows(handles);


function [arbConfig saConfig] = makeArbConfig(handles)
% retrieve all the field values
clear arbConfig;
arbModels = cellstr(get(handles.popupmenuModel, 'String'));
arbModel = arbModels{get(handles.popupmenuModel, 'Value')};
arbConfig.model = arbModel;
connTypes = cellstr(get(handles.popupmenuConnectionType, 'String'));
connType = connTypes{get(handles.popupmenuConnectionType, 'Value')};
arbConfig.connectionType = connType;
arbConfig.visaAddr = strtrim(get(handles.editVisaAddr, 'String'));
arbConfig.ip_address = get(handles.editIPAddress, 'String');
arbConfig.port = evalin('base', get(handles.editPort, 'String'));
arbConfig.defaultFc = evalin('base', get(handles.editDefaultFc, 'String'));
arbConfig.tooltips = get(handles.checkboxTooltips, 'Value');
arbConfig.amplitudeScaling = evalin('base', get(handles.editAmplScale, 'String'));
if (get(handles.checkboxSetCarrierFreq, 'Value'))
    arbConfig.carrierFrequency = evalin('base', get(handles.editCarrierFreq, 'String'));
end
if (get(handles.checkboxSetSkew, 'Value'))
    arbConfig.skew = evalin('base', get(handles.editSkew, 'String'));
end
if (get(handles.checkboxSetGainCorr, 'Value'))
    arbConfig.gainCorrection = evalin('base', get(handles.editGainCorr, 'String'));
end
trigList = get(handles.popupmenuTrigger, 'String');
trigVal = trigList{get(handles.popupmenuTrigger, 'Value')};
arbConfig.triggerMode = trigVal;
if (get(handles.checkboxSetAmpl, 'Value'))
    ampl1 = evalin('base', get(handles.editAmpl1, 'String'));
    ampl2 = evalin('base', get(handles.editAmpl2, 'String'));
    arbConfig.amplitude = [ampl1 ampl2];
end
if (get(handles.checkboxSetOffs, 'Value'))
    offs1 = evalin('base', get(handles.editOffs1, 'String'));
    offs2 = evalin('base', get(handles.editOffs2, 'String'));
    arbConfig.offset = [offs1 offs2];
end
if (get(handles.checkboxSetAmpType, 'Value'))
    ampTypes = cellstr(get(handles.popupmenuAmpType, 'String'));
    ampType = ampTypes{get(handles.popupmenuAmpType, 'Value')};
    arbConfig.ampType = ampType;
end
if (get(handles.checkboxRST, 'Value'))
    arbConfig.do_rst = true;
end
if (get(handles.checkboxExtClk, 'Value'))
    arbConfig.extClk = true;
end
if (get(handles.checkboxInterleaving, 'Value'))
    arbConfig.interleaving = true;
end
if (get(handles.checkboxVisaAddr2, 'Value'))
    arbConfig.visaAddr2 = strtrim(get(handles.editVisaAddr2, 'String'));
end
if (get(handles.checkboxVisaAddrM8192A, 'Value'))
    arbConfig.useM8192A = 1;
else
    arbConfig.useM8192A = 0;
end
arbConfig.visaAddrM8192A = strtrim(get(handles.editVisaAddrM8192A, 'String'));
if (get(handles.checkboxVisaAddrScope, 'Value'))
    arbConfig.visaAddrScope = strtrim(get(handles.editVisaAddrScope, 'String'));
end
% spectrum analyzer connections
clear saConfig;
saConfig.connected = get(handles.checkboxSAattached, 'Value');
saConfig.connectionType = 'visa';
saConfig.visaAddr = get(handles.editVisaAddrSA, 'String');
saAlgoIdx = get(handles.popupmenuSAAlgorithm, 'Value');
switch (saAlgoIdx)
    case 1 % zero span
        saConfig.useListSweep = 0;
        saConfig.useMarker = 0;
    case 2 % marker
        saConfig.useListSweep = 0;
        saConfig.useMarker = 1;
    case 3 % list sweep
        saConfig.useListSweep = 1;
        saConfig.useMarker = 0;
end


function notifyIQToolWindows(handles)
% Notify all open iqtool utilities that arbConfig has changed 
% Figure windows are recognized by their "iqtool" tag
try
    TempHide = get(0, 'ShowHiddenHandles');
    set(0, 'ShowHiddenHandles', 'on');
    figs = findobj(0, 'Type', 'figure', 'Tag', 'iqtool');
    set(0, 'ShowHiddenHandles', TempHide);
    for i = 1:length(figs)
        fig = figs(i);
        [path file ext] = fileparts(get(fig, 'Filename'));
        handles = guihandles(fig);
        feval(file, 'checkfields', fig, 'red', handles);
    end
catch ex
    errordlg({ex.message, [ex.stack(1).name ', line ' num2str(ex.stack(1).line)]});
end


% --- Executes on button press in checkboxExtClk.
function checkboxExtClk_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxExtClk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkboxExtClk
paramChangedNote(handles);


function editVisaAddr_Callback(hObject, eventdata, handles)
% hObject    handle to editVisaAddr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editVisaAddr as text
%        str2double(get(hObject,'String')) returns contents of editVisaAddr as a double
checkVisaAddr(handles);


% --- Executes during object creation, after setting all properties.
function editVisaAddr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editVisaAddr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in checkboxSAattached.
function checkboxSAattached_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxSAattached (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkboxSAattached
saConnected = get(handles.checkboxSAattached, 'Value');
if (~saConnected)
    set(handles.editVisaAddrSA, 'Enable', 'off');
    set(handles.popupmenuSAAlgorithm, 'Enable', 'off');
    set(handles.pushbuttonTestSA, 'Enable', 'off');
    set(handles.pushbuttonTestSA, 'Background', [.9 .9 .9]);
else
    set(handles.editVisaAddrSA, 'Enable', 'on');
    set(handles.popupmenuSAAlgorithm, 'Enable', 'on');
    set(handles.pushbuttonTestSA, 'Enable', 'on');
end


function editVisaAddrSA_Callback(hObject, eventdata, handles)
% hObject    handle to editVisaAddrSA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editVisaAddrSA as text
%        str2double(get(hObject,'String')) returns contents of editVisaAddrSA as a double


% --- Executes during object creation, after setting all properties.
function editVisaAddrSA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editVisaAddrSA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in popupmenuSAAlgorithm.
function popupmenuSAAlgorithm_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSAAlgorithm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of popupmenuSAAlgorithm


% --- Executes on selection change in popupmenuModel.
function popupmenuModel_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuModel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuModel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuModel
arbModels = cellstr(get(handles.popupmenuModel, 'String'));
arbModel = arbModels{get(handles.popupmenuModel, 'Value')};
if (~isempty(strfind(arbModel, 'DUC')))
    set(handles.textCarrierFreq, 'Enable', 'on');
    set(handles.checkboxSetCarrierFreq, 'Enable', 'on');
    checkboxSetCarrierFreq_Callback(hObject, eventdata, handles);
else
    set(handles.textCarrierFreq, 'Enable', 'off');
    set(handles.editCarrierFreq, 'Enable', 'off');
    set(handles.checkboxSetCarrierFreq, 'Enable', 'off');
end
% M8195A_Rev0 does not use VISA addressing
if (~isempty(strfind(arbModel, 'M8195A_Rev0')))
    set(handles.editVisaAddr, 'Enable', 'off');
    set(handles.editIPAddress, 'Enable', 'off');
    set(handles.editPort, 'Enable', 'off');
    set(handles.popupmenuConnectionType, 'Enable', 'off');
else
    set(handles.popupmenuConnectionType, 'Enable', 'on');
    popupmenuConnectionType_Callback(hObject, eventdata, handles);
end
% trigger is only implemented for M8190A (so far)
if (~isempty(strfind(arbModel, 'M8190A')))
    set(handles.popupmenuTrigger, 'Enable', 'on');
else
    set(handles.popupmenuTrigger, 'Enable', 'off');
end
% amplifier type only for M8190A and 81180A/B
if (~isempty(strfind(arbModel, 'M8190A')) || ~isempty(strfind(arbModel, '81180')))
    set(handles.popupmenuAmpType, 'Enable', 'on');
else
    set(handles.popupmenuAmpType, 'Enable', 'off');
end
% amplitude/offset for M8190A, 81180A, 81150A, 81160A
if (~isempty(strfind(arbModel, 'M8190A')) || ~isempty(strfind(arbModel, '81180')) || ...
    ~isempty(strfind(arbModel, '81150A')) || ~isempty(strfind(arbModel, '81160A')))
    set(handles.checkboxSetAmpl, 'Enable', 'on');
    set(handles.checkboxSetOffs, 'Enable', 'on');
else
    set(handles.checkboxSetAmpl, 'Enable', 'off');
    set(handles.checkboxSetOffs, 'Enable', 'off');
end
checkVisaAddr(handles);


% --- Executes during object creation, after setting all properties.
function popupmenuModel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuModel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonApply.
function pushbuttonApply_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonApply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
saveConfig(handles);
if (get(handles.checkboxExtClk, 'Value') == 1)
    errordlg(['Can''t apply settings to hardware with external clock turned on. ' ...
              'Please press "OK" and re-download your waveform']);
else
    iqdownload([], 0);
end



function editOffs1_Callback(hObject, eventdata, handles)
% hObject    handle to editOffs1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editOffs1 as text
%        str2double(get(hObject,'String')) returns contents of editOffs1 as a double
paramChangedNote(handles);



function editOffs2_Callback(hObject, eventdata, handles)
% hObject    handle to editOffs2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editOffs2 as text
%        str2double(get(hObject,'String')) returns contents of editOffs2 as a double
paramChangedNote(handles);


% --- Executes during object creation, after setting all properties.
function editOffs2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editOffs2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxSetOffs.
function checkboxSetOffs_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxSetOffs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxSetOffs
val = get(hObject,'Value');
onoff = {'off' 'on'};
set(handles.editOffs1, 'Enable', onoff{val+1});
set(handles.editOffs2, 'Enable', onoff{val+1});
paramChangedNote(handles);


% --- Executes on button press in checkboxRST.
function checkboxRST_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxRST (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxRST
paramChangedNote(handles);


function editDefaultFc_Callback(hObject, eventdata, handles)
% hObject    handle to editDefaultFc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDefaultFc as text
%        str2double(get(hObject,'String')) returns contents of editDefaultFc as a double
value = [];
try
    value = evalin('base', ['[' get(hObject, 'String') ']']);
catch ex
    msgbox(ex.message);
end
if (isscalar(value) && value <= 1e11 && value >= 0)
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor','red');
end


% --- Executes during object creation, after setting all properties.
function editDefaultFc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDefaultFc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxTooltips.
function checkboxTooltips_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxTooltips (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxTooltips



function editAmplScale_Callback(hObject, eventdata, handles)
% hObject    handle to editAmplScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editAmplScale as text
%        str2double(get(hObject,'String')) returns contents of editAmplScale as a double
value = [];
try
    value = evalin('base', ['[' get(hObject, 'String') ']']);
catch ex
    msgbox(ex.message);
end
if (isscalar(value) && value <= 1 && value >= 0)
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor','red');
end
paramChangedNote(handles);


% --- Executes during object creation, after setting all properties.
function editAmplScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editAmplScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menuFile_Callback(hObject, eventdata, handles)
% hObject    handle to menuFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuLoadSettings_Callback(hObject, eventdata, handles)
% hObject    handle to menuLoadSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName] = uigetfile('.fig');
if(FileName~=0)
    try
        cf = gcf;
        hgload(strcat(PathName,FileName));
        close(cf);
    catch ex
        errordlg(ex.message);
    end
end   

% --------------------------------------------------------------------
function menuSaveSettings_Callback(hObject, eventdata, handles)
% hObject    handle to menuSaveSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName] = uiputfile('.fig');
if(FileName~=0)
    hgsave(strcat(PathName,FileName));
end   


% --- Executes on button press in checkboxInterleaving.
function checkboxInterleaving_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxInterleaving (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxInterleaving
if (get(hObject,'Value'))
    msgbox({'Please use the GUI or Soft Front Panel of the AWG to adjust' ...
            'channel 2 to be delayed by 1/2 sample period with respect to' ...
            'channel 1. An easy way to check the correct delay is to generate' ...
            'a multitone signal with tones between DC and fs/4, observe the' ...
            'signal on a spectrum analyzer and adjust the channel 2 delay' ...
            'until the images in the second Nyquist band are minimial.'}, 'Note');
end



function editCarrierFreq_Callback(hObject, eventdata, handles)
% hObject    handle to editCarrierFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editCarrierFreq as text
%        str2double(get(hObject,'String')) returns contents of editCarrierFreq as a double
paramChangedNote(handles);


% --- Executes during object creation, after setting all properties.
function editCarrierFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editCarrierFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxSetCarrierFreq.
function checkboxSetCarrierFreq_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxSetCarrierFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkboxSetCarrierFreq
val = get(handles.checkboxSetCarrierFreq, 'Value');
onoff = {'off' 'on'};
set(handles.editCarrierFreq, 'Enable', onoff{val+1});
%paramChangedNote(handles);


function paramChangedNote(handles)
% at least one parameter has changed --> notify user that the change will
% only be sent to hardware on the next waveform download
set(handles.textNote, 'Background', 'yellow');


function checkVisaAddr(handles)
visaAddr = upper(strtrim(get(handles.editVisaAddr, 'String')));
connTypes = cellstr(get(handles.popupmenuConnectionType, 'String'));
connType = connTypes{get(handles.popupmenuConnectionType, 'Value')};
arbModels = cellstr(get(handles.popupmenuModel, 'String'));
arbModel = arbModels{get(handles.popupmenuModel, 'Value')};
if (~isempty(strfind(arbModel, 'M8190')) && ...
    strcmpi(connType, 'visa') && ...
    isempty(strfind(visaAddr, 'TCPIP')))
    msgbox({'You selected the M8190A, but the Visa address that you specified' ...
            'does not start with TCPIP. Please use one of the visa addresses' ...
            'shown in the M8190A firmware window that starts with TCPIP...'}, 'replace');
end


% --- Executes on button press in checkboxVisaAddrScope.
function checkboxVisaAddrScope_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxVisaAddrScope (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxVisaAddrScope
scopeConnected = get(handles.checkboxVisaAddrScope, 'Value');
if (~scopeConnected)
    set(handles.editVisaAddrScope, 'Enable', 'off');
    set(handles.pushbuttonTestScope, 'Enable', 'off');
    set(handles.pushbuttonTestScope, 'Background', [.9 .9 .9]);
else
    set(handles.editVisaAddrScope, 'Enable', 'on');
    set(handles.pushbuttonTestScope, 'Enable', 'on');
end



function editVisaAddrScope_Callback(hObject, eventdata, handles)
% hObject    handle to editVisaAddrScope (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editVisaAddrScope as text
%        str2double(get(hObject,'String')) returns contents of editVisaAddrScope as a double


% --- Executes during object creation, after setting all properties.
function editVisaAddrScope_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editVisaAddrScope (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxVisaAddr2.
function checkboxVisaAddr2_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxVisaAddr2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxVisaAddr2
awg2Connected = get(handles.checkboxVisaAddr2, 'Value');
if (~awg2Connected)
    set(handles.editVisaAddr2, 'Enable', 'off');
    set(handles.pushbuttonTestAWG2, 'Enable', 'off');
    set(handles.pushbuttonTestAWG2, 'Background', [.9 .9 .9]);
    set(handles.pushbuttonSwapAWG, 'Enable', 'off');
else
    set(handles.editVisaAddr2, 'Enable', 'on');
    set(handles.pushbuttonSwapAWG, 'Enable', 'on');
    set(handles.pushbuttonTestAWG2, 'Enable', 'on');
    % try to guess the address for the slave AWG if it has never been set
    if (~isempty(strfind(get(handles.editVisaAddr2, 'String'), 'Enter')))
        addr = get(handles.editVisaAddr, 'String');
        addr2 = regexprep(addr, '::inst([0-9]*)', '::inst${num2str(str2double($1)+1)}');
        addr2 = regexprep(addr2, '::hislip([0-9]*)', '::hislip${num2str(str2double($1)+1)}');
        addr2 = regexprep(addr2, '::([0-9]*)::', '::${num2str(str2double($1)+1)}::');
        set(handles.editVisaAddr2, 'String', addr2);
    end
end


function editVisaAddr2_Callback(hObject, eventdata, handles)
% hObject    handle to editVisaAddr2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editVisaAddr2 as text
%        str2double(get(hObject,'String')) returns contents of editVisaAddr2 as a double


% --- Executes during object creation, after setting all properties.
function editVisaAddr2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editVisaAddr2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonTestScope.
function pushbuttonTestScope_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonTestScope (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
scopeCfg.connectionType = 'visa';
scopeCfg.visaAddr = get(handles.editVisaAddrScope, 'String');
found = 0;
hMsgBox = msgbox('Trying to connect, please wait...', 'Please wait...', 'replace');
f = iqopen(scopeCfg);
try close(hMsgBox); catch ex; end
if (~isempty(f))
    try
        res = query(f, '*IDN?');
        if (~isempty(strfind(res, 'Agilent Technologies,DSO')) || ...
            ~isempty(strfind(res, 'Agilent Technologies,DSA')) || ...
            ~isempty(strfind(res, 'Agilent Technologies,MSO')))
            found = 1;
        else
            errordlg({'Unexpected scope model:' '' res ...
                'Supported models are Agilent DSO, DSA or MSO'});
        end
    catch ex
        errordlg({'Error reading scope IDN:' '' ex.message});
    end
    fclose(f);
end
if (found)
    set(hObject, 'Background', 'green');
else
    set(hObject, 'Background', 'red');
end


% --- Executes on button press in pushbuttonTestAWG2.
function pushbuttonTestAWG2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonTestAWG2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[cfg dummy] = makeArbConfig(handles);
cfg.connectionType = 'visa';
cfg.visaAddr = strtrim(get(handles.editVisaAddr2, 'String'));
testConnection(hObject, cfg);


% --- Executes on button press in pushbuttonTestAWG1.
function pushbuttonTestAWG1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonTestAWG1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[cfg dummy] = makeArbConfig(handles);
testConnection(hObject, cfg);



function result = testConnection(hObject, arbConfig)
model = arbConfig.model;
checkmodel = [];
checkfeature = [];
if (~isempty(strfind(model, 'M8190')))
    checkmodel = 'M8190A';
elseif (~isempty(strfind(model, '81180')))
    checkmodel = '81180';
elseif (~isempty(strfind(model, '81150')))
    checkmodel = '81150';
elseif (~isempty(strfind(model, '81160')))
    checkmodel = '81160';
elseif (~isempty(strfind(model, 'N5182A')))
    checkmodel = 'N5182A';
elseif (~isempty(strfind(model, 'N5182B')))
    checkmodel = 'N5182B';
elseif (~isempty(strfind(model, 'N5172B')))
    checkmodel = 'N5172B';
elseif (~isempty(strfind(model, 'E4438C')))
    checkmodel = 'E4438C';
elseif (~isempty(strfind(model, 'E8267D')))
    checkmodel = 'E8267D';
else
    msgbox({'The "Test Connection" function is not yet implemented for this model.' ...
            'Please download a waveform and observe error messages'});
    result = 1;
    return;
end
if (~isempty(strfind(model, 'DUC')))
    checkfeature = 'DUC';
end
hMsgBox = msgbox('Trying to connect, please wait...', 'Please wait...', 'replace');
if (iqoptcheck(arbConfig, [], checkfeature, checkmodel))
    set(hObject, 'Background', 'green');
    result = 1;
else
    set(hObject, 'Background', 'red');
    result = 0;
end
try close(hMsgBox); catch ex; end


% --- Executes on button press in pushbuttonTestSA.
function pushbuttonTestSA_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonTestSA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[dummy saCfg] = makeArbConfig(handles);
hMsgBox = msgbox('Trying to connect, please wait...', 'Please wait...', 'replace');
f = iqopen(saCfg);
try close(hMsgBox); catch ex; end
found = 0;
if (~isempty(f))
    res = query(f, '*IDN?');
    if (~isempty(strfind(res, 'E444')) || ...
        ~isempty(strfind(res, 'N9020')) || ...
        ~isempty(strfind(res, 'N9030')))
        found = 1;
    else
        errordlg({'Unexpected spectrum analyzer type:' '' res ...
            'Supported models are PSA (E444xA), MXA (N9020A) and PXA (N9030A)'});
    end
    fclose(f);
end
if (found)
    set(hObject, 'Background', 'green');
else
    set(hObject, 'Background', 'red');
end


% --- Executes on button press in pushbuttonSwapAWG.
function pushbuttonSwapAWG_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSwapAWG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
awg1 = get(handles.editVisaAddr, 'String');
awg2 = get(handles.editVisaAddr2, 'String');
set(handles.editVisaAddr2, 'String', awg1);
set(handles.editVisaAddr, 'String', awg2);
set(handles.popupmenuConnectionType, 'Value', 2);
popupmenuConnectionType_Callback([], [], handles);


% --- Executes on button press in pushbuttonTestM8192A.
function pushbuttonTestM8192A_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonTestM8192A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
M8192ACfg.connectionType = 'visa';
M8192ACfg.visaAddr = strtrim(get(handles.editVisaAddrM8192A, 'String'));
found = 0;
hMsgBox = msgbox('Trying to connect, please wait...', 'Please wait...', 'replace');
ch = get(hMsgBox, 'Children');
set(ch(2), 'String', 'Close');
f = iqopen(M8192ACfg);
try close(hMsgBox); catch ex; end
if (~isempty(f))
    try
        res = query(f, '*IDN?');
        if (~isempty(strfind(res, 'M8192A')))
            found = 1;
        else
            errordlg({'Unexpected IDN response:' '' res ...
                'Please specify the VISA address of an M8192A module' ...
                'and make sure the corresponding firmware is running'});
        end
    catch ex
        errordlg({'Error reading IDN:' '' ex.message});
    end
    fclose(f);
end
if (found)
    set(hObject, 'Background', 'green');
else
    set(hObject, 'Background', 'red');
end


function editVisaAddrM8192A_Callback(hObject, eventdata, handles)
% hObject    handle to editVisaAddrM8192A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editVisaAddrM8192A as text
%        str2double(get(hObject,'String')) returns contents of editVisaAddrM8192A as a double


% --- Executes during object creation, after setting all properties.
function editVisaAddrM8192A_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editVisaAddrM8192A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxVisaAddrM8192A.
function checkboxVisaAddrM8192A_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxVisaAddrM8192A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkboxVisaAddrM8192A
M8192AConnected = get(handles.checkboxVisaAddrM8192A, 'Value');
if (~M8192AConnected)
    set(handles.editVisaAddrM8192A, 'Enable', 'off');
    set(handles.pushbuttonTestM8192A, 'Enable', 'off');
    set(handles.pushbuttonTestM8192A, 'Background', [.9 .9 .9]);
    answer = questdlg({'Do you want to re-configure the M8192A to let'
        'the M8190A modules run individually?'}, 'M8192A configuration');
    switch (answer)
        case 'Yes'
            hMsgBox = msgbox('Trying to connect, please wait...', 'Please wait...', 'replace');
            try
                arbConfig = loadArbConfig();
                arbConfig.visaAddr = arbConfig.visaAddrM8192A;
                fsync = iqopen(arbConfig);
                fprintf(fsync, ':ABOR');
                fprintf(fsync, ':inst:mmod:conf 1');
                fprintf(fsync, ':inst:slave:del:all');
                fprintf(fsync, ':inst:mast ""');
                query(fsync, '*opc?');
                fclose(fsync);
            catch ex
                msgbox(ex.message);
            end
            try close(hMsgBox); catch ex; end
        case 'No'
            % do nothing
        case 'Cancel'
            set(handles.checkboxVisaAddrM8192A, 'Value', 1);
    end
else
    if (~get(handles.checkboxVisaAddr2, 'Value'))
        msgbox({'Please configure a second M8190A module first'});
        set(handles.checkboxVisaAddrM8192A, 'Value', 0);
    else
        set(handles.editVisaAddrM8192A, 'Enable', 'on');
        set(handles.pushbuttonTestM8192A, 'Enable', 'on');
        msgbox({'NOTE: When this checkbox is checked, the two M8190A modules will' ...
            '(all 4 channels) will run synchronously. Please make sure you load' ...
            'waveforms to all 4 channels. In order to improve the skew, please use' ...
            'the "4-channel sync" utility or the "C-PHY generator demo" utility.' ...
            'If you want to use the M8190A individually, please uncheck this checkbox'});
    end
end


% --- Executes on selection change in popupmenuTrigger.
function popupmenuTrigger_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuTrigger (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuTrigger contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuTrigger
paramChangedNote(handles);


% --- Executes during object creation, after setting all properties.
function popupmenuTrigger_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuTrigger (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxSetGainCorr.
function checkboxSetGainCorr_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxSetGainCorr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxSetGainCorr
val = get(hObject,'Value');
onoff = {'off' 'on'};
set(handles.editGainCorr, 'Enable', onoff{val+1});
paramChangedNote(handles);



function editGainCorr_Callback(hObject, eventdata, handles)
% hObject    handle to editGainCorr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editGainCorr as text
%        str2double(get(hObject,'String')) returns contents of editGainCorr as a double


% --- Executes during object creation, after setting all properties.
function editGainCorr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editGainCorr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
