%=================================================================================================================================
%% Script for preprocessing Ego and targets Data in global,ego fixed and target fixed coordinate system   %%
%% Run this function for getting Excel sheets. %%
%% Author: Bhagyaraj Dharmana(AST-42)
%% Date  : 25.01.2019
%%
%   tracePath                : the absolute path of the trace
%   traceName                : Name of the specific trace folder
%   plotData                 : 0 -> don't plot trajectory data/ 1 -> plot Original trajectory Data/ 2 -> plot postprocessed Data
%   minDistBetwTargets       : minimum distance ( in m) between a projected target and an existing one to separate them as 2 physical targets
%   minTargetExistTimeStamps : Minimum Number of timestamps to consider a processed Target
%   saveProcessedData        : boolean, true if user want to save processed objects dynamic data in xlsx sheets
%   distance2holdingLine     : Distance between the ego and the holding line in both directions(right and left)
%% Output  :
%   From MATLAB                data : a struct containing ego and targets original and processed dynamic data as well as their existence ranges in the scene
%   For Python                 TextFiles containg information about Target
%                              1.Target Relavancy
%                              2.Target Label
%                              3.Reason for the label
%                              4.Tj--Time at which the target is crossing the holding line
%% Functions:
%              1.dynamicdataProcessing:   Function for preprocessing Ego and targets Data and visualisation.
%              2.extractStaticPortions:   Function to find static scenes of ego and relavant targets in that existence range
%              3.trafoGC2EFC          :   Function to Transform from Global coordinates to EGO fixed coordinates(EFC)
%              4.trafoGC2TFC          :   Function to Transform from Global coordinates to Target fixed coordinates(TFC)
%              5.saveProcessedData2xls:   Function to save processed data to Xlsx file
%=================================================================================================================================
%--------------------------------------------------------------------------
clear;
close all;
clc;
%--------------------------------------------------------------------------
%% Define Paths
%--------------------------------------------------------------------------
tracesAbsPath='F:\kasTracesData_filtered';
saveLabelPath='D:\PUBLIC\Internship\intentionrecognitionKAS\labeledData';
%--------------------------------------------------------------------------
%% call Parameters script
%--------------------------------------------------------------------------
definePar;
%--------------------------------------------------------------------------
%% Check if EFC and TFC subfolders are existing in saveLabelPath
%--------------------------------------------------------------------------
efcSF=[saveLabelPath, '\EFC'];
tfcSF=[saveLabelPath, '\TFC'];
if isfolder(efcSF)
    rmdir(efcSF,'s');
end
mkdir(efcSF)
if isfolder(tfcSF)
    rmdir(tfcSF,'s');
end
mkdir(tfcSF)
%--------------------------------------------------------------------------
%% Start the loop for labeling process
%--------------------------------------------------------------------------
scriptsAbsPath=pwd;
listKat=dir(tracesAbsPath);
cd([scriptsAbsPath '\functions\Matlab']);
for ii=3:length(listKat)
    if (listKat(ii).isdir)
        tracesPath=fullfile(tracesAbsPath,listKat(ii).name);
        list=dir(tracesPath);
        for jj=3:length(list)
            traceName=list(jj).name;
            disp(traceName);
            data = labelingProcessSingleTrace(scriptsAbsPath,tracesPath,traceName,saveLabelPath,par);
        end
    end
end
%--------------------------------------------------------------------------
%% Call statistic function
%--------------------------------------------------------------------------
labeledDataReadMe(saveLabelPath,par);