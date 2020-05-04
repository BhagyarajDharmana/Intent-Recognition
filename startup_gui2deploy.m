%------------------------------------------------------------------------------------------------------------------------------------------
%% script to call for getting the Gui window
%% User should select the Absolute path where the folder in the below structure is there
%       1.Functions(This folder contains two folders Matlab amd Python
%       2.Labelled Data(This folder will save the text files after labelling)
%       3.startup_gui.m (Script for GUI start up)
%------------------------------------------------------------------------------------------------------------------------------------------
close all;
clear;
clc;
%--------------------------------------------------------------------------
%% call Parameters script
%--------------------------------------------------------------------------
definePar;
%--------------------------------------------------------------------------
%------------------------------------------------------------------------------------------------------------------------------------------
%% Define relevant model details
%------------------------------------------------------------------------------------------------------------------------------------------
useEFC4Deploying = true;
useTj4Deploying = true;
maxDataLength=382;                                                         % maximum timestamps (changes depending on the model to deploy)
modelFolderName='190429_102400_EFC_tj';
%------------------------------------------------------------------------------------------------------------------------------------------
scriptsAbsPath=pwd;
path2functions = [scriptsAbsPath,'\functions\'];
cd([path2functions,'\Matlab\gui']);
%------------------------------------------------------------------------------------------------------------------------------------------
Scene_Analyzer_GUIModel = Scene_Analyzer_GUI_Model(scriptsAbsPath,par,useEFC4Deploying,useTj4Deploying,modelFolderName,maxDataLength);
Scene_Analyzer_GUI_Controller(Scene_Analyzer_GUIModel);
%------------------------------------------------------------------------------------------------------------------------------------------