function varargout = Scene_Analyzer_GUI(varargin)
% SCENE_ANALYZER_GUI MATLAB code for Scene_Analyzer_GUI.fig
%      SCENE_ANALYZER_GUI, by itself, creates a new SCENE_ANALYZER_GUI or raises the existing
%      singleton*.
%
%      H = SCENE_ANALYZER_GUI returns the handle to a new SCENE_ANALYZER_GUI or the handle to
%      the existing singleton*.
%
%      SCENE_ANALYZER_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SCENE_ANALYZER_GUI.M with the given input arguments.
%
%      SCENE_ANALYZER_GUI('Property','Value',...) creates a new SCENE_ANALYZER_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Scene_Analyzer_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Scene_Analyzer_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Scene_Analyzer_GUI

% Last Modified by GUIDE v2.5 26-Mar-2019 10:13:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Scene_Analyzer_GUI_OpeningFcn, ...
    'gui_OutputFcn',  @Scene_Analyzer_GUI_OutputFcn, ...
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


% --- Executes just before Scene_Analyzer_GUI is made visible.
function Scene_Analyzer_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Scene_Analyzer_GUI (see VARARGIN)

% Choose default command line output for Scene_Analyzer_GUI
handles.output = hObject;

% get handle to the controller
for i = 1:2:length(varargin)
    switch varargin{i}
        case 'cController'
            handles.cController = varargin{i+1};
        otherwise
            error('unknown input')
    end
end



% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Scene_Analyzer_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Scene_Analyzer_GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbuttonSelectTrace.
function pushbuttonSelectTrace_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSelectTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.cController.OpenTraceFolder();


% --- Executes on button press in pushbuttonRun.
function pushbuttonRun_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.cController.RunEval();

% --- Executes on selection change in popupmenuTypeofplot.
function popupmenuTypeofplot_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuTypeofplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuTypeofplot contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuTypeofplot


% --- Executes during object creation, after setting all properties.
function popupmenuTypeofplot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuTypeofplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuID.
function popupmenuID_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuID contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuID


% --- Executes during object creation, after setting all properties.
function popupmenuID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenucoordinatestype.
function popupmenucoordinatestype_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenucoordinatestype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenucoordinatestype contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenucoordinatestype


% --- Executes during object creation, after setting all properties.
function popupmenucoordinatestype_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenucoordinatestype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonplot.
function pushbuttonplot_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.cController.plotCurves();


% --- Executes on button press in checkboxDeploy.
function checkboxDeploy_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxDeploy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxDeploy


% --- Executes on button press in checkboxPropogate.
function checkboxPropogate_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxPropogate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxPropogate


% --- Executes on button press in pushbuttonDeploy.
function pushbuttonDeploy_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDeploy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
