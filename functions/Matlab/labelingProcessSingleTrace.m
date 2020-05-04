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



function data = labelingProcessSingleTrace(scripts_absolutePath,tracesPath,traceName,saveLabelPath,par)

matlabFunctionsPath=[scripts_absolutePath, '\functions\matlab'];
%--------------------------------------------------------------------------
%% read Parameters
%--------------------------------------------------------------------------
plotData=par.plotData;
plotStaticPortionsTrafo=par.plotStaticPortionsTrafo;
minDistBetwTargets=par.minDistBetwTargets;                                 % [m]
minTargetExistTimeStamps=par.minTargetExistTimeStamps;
saveProcessedData=par.saveProcessedData;
min_ego_speed=par.min_ego_speed;                                           % [m/s] --> 21.6 [Km/h]
distance2holdingLine=par.distance2holdingLine;                             % parameter relevant vor tj estimation
%--------------------------------------------------------------------------
savePath = [tracesPath,'\' traceName];
cd(matlabFunctionsPath)
%--------------------------------------------------------------------------
%% Function for pre processing of Ego and target data in Global coordinate sytem
%--------------------------------------------------------------------------
data=dynamicdataProcessing(tracesPath,traceName ,plotData,minDistBetwTargets,minTargetExistTimeStamps,false);
if data.pp.holeTrace.numberOfTargets>0
    %--------------------------------------------------------------------------
    %% Function for Extracting the static portions in the trace.
    %--------------------------------------------------------------------------
    data=extractStaticPortions(data,min_ego_speed);
    %--------------------------------------------------------------------------
    %% Functions to transform global cordinates toEgo fixed coodinates and Target fixed coordinates
    %--------------------------------------------------------------------------
    data=trafoGC2EFC(data);       %EFC = Ego fixed coordinates
    data=trafoGC2TFC(data);       %TFC = Target Fixed coordinates
    %--------------------------------------------------------------------------
    %% save processed data in xlsx if desired
    %--------------------------------------------------------------------------
    if (saveProcessedData)
        saveProcessedData2xls(savePath,traceName,data);
    end
    data.par.distance2holdingLine=distance2holdingLine;
    data.par.min_ego_speed=min_ego_speed;
    %--------------------------------------------------------------------------
    %% test static portions trafo
    %--------------------------------------------------------------------------
    if (plotStaticPortionsTrafo)
        for i=1:data.pp.staticTraces.nbr_staticPortions
            data_sp=data.pp.staticTraces.(strcat('SP_',num2str(i)));
            range=data_sp.existenceRange;
            f=figure('NumberTitle', 'off', 'Name',['SP_',num2str(i)]);
            for j=1:length(data_sp.relevantTargetsID)
                ID_orig=data.pp.holeTrace.targets.(data_sp.relevantTargetsID{j});
                ID_efc=data_sp.EFC.(data_sp.relevantTargetsID{j});
                ID_tfc=data_sp.TFC.(data_sp.relevantTargetsID{j});
                ego_Portion=data.egoData(range(1):range(2),:);
                c=rand(3,1);
                subplot(2,2,1);
                grid on;
                hold on;
                %plot(ego_Portion(1,2),ego_Portion(:,3),'g');
                plot(ID_efc(:,2),ID_efc(:,3),'Color',c);
                title('rel. targets in EFC');
                subplot(2,2,2);
                grid on;
                hold on;
                %plot(ego_Portion(:,2),ego_Portion(:,3),'g');
                plot(ID_tfc(:,2),ID_tfc(:,3),'Color',c);
                title('rel. targets in TFC');
                subplot(2,2,3);
                grid on;
                hold on;
                plot(ID_efc(:,1),ID_efc(:,8),'Color',c);
                plot(ID_tfc(:,1),ID_tfc(:,8),'Color',c);
                title('yaw angles in TFC and EFC')
                subplot(2,2,4);
                grid on;
                hold on;
                plot(ego_Portion(:,2),ego_Portion(:,3),'g');
                plot(ID_orig(:,2),ID_orig(:,3),'Color',c);
                title('original GC')
            end
        end
    end
    %% --------------------------------------------------------------------------
    %% Script for data labeling. Labels will be saved as text in ./data subfolder
    %% --------------------------------------------------------------------------
    % initialise labels substructurs in data struct
    ppIDs=fieldnames(data.pp.holeTrace.targets);
    for ii=1:length(ppIDs)
        data.pp.targetsLabel.(ppIDs{ii}).relevancy=-1;
        data.pp.targetsLabel.(ppIDs{ii}).label=-1;
        data.pp.targetsLabel.(ppIDs{ii}).tj=inf;
        data.pp.targetsLabel.(ppIDs{ii}).comment='Target ID does not belong to any static portion in this scene.';
    end
    %Check label and save txt file
    savePath_EFC=[saveLabelPath, '\EFC\'];
    savePath_TFC=[saveLabelPath, '\TFC\'];
    IDs=fieldnames(data.pp.holeTrace.targets);
    scenenames= fieldnames(data.pp.staticTraces);
    scene_lenght = data.time(end);
    num_of_SP = data.pp.staticTraces.nbr_staticPortions;
    disp(['Duration of the scene is: ' num2str(scene_lenght) ' seconds']);
    disp(['Number of static portions: ' num2str(num_of_SP)]);
    if exist([savePath_EFC,traceName,'.txt'],'file')==2
        delete([savePath_EFC,traceName,'.txt']);
    end
    dlmwrite([savePath_EFC,traceName,'.txt'],'******-------------------------------------------------------------------------------------------------------------------****** ',...
        'delimiter','','newline','pc','-append');
    dlmwrite([savePath_EFC,traceName,'.txt'],['Duration of the scene is: ' num2str(scene_lenght) ' seconds'],'delimiter','','newline','pc','-append');
    dlmwrite([savePath_EFC,traceName,'.txt'],['Original Targets Numbers in the hole Scene: ' num2str(data.orig.numberOfTargets)],'delimiter','','newline','pc','-append');
    dlmwrite([savePath_EFC,traceName,'.txt'],['Number of Targets in the hole Scene after preprocessing: ' num2str(data.pp.holeTrace.numberOfTargets)],'delimiter','','newline','pc','-append');
    dlmwrite([savePath_EFC,traceName,'.txt'],['Number of static portions: ' num2str(num_of_SP)],'delimiter','','newline','pc','-append');
    dlmwrite([savePath_EFC,traceName,'.txt'],'******-------------------------------------------------------------------------------------------------------------------****** ',...
        'delimiter','','newline','pc','-append');
    if exist([savePath_TFC,traceName,'.txt'],'file')==2
        delete([savePath_TFC,traceName,'.txt']);
    end
    dlmwrite([savePath_TFC,traceName,'.txt'],'******-------------------------------------------------------------------------------------------------------------------****** ',...
        'delimiter','','newline','pc','-append');
    dlmwrite([savePath_TFC,traceName,'.txt'],['Duration of the scene is: ' num2str(scene_lenght) ' seconds'],'delimiter','','newline','pc','-append');
    dlmwrite([savePath_TFC,traceName,'.txt'],['Original Targets Numbers in the hole Scene: ' num2str(data.orig.numberOfTargets)],'delimiter','','newline','pc','-append');
    dlmwrite([savePath_TFC,traceName,'.txt'],['Number of Targets in the hole Scene after preprocessing: ' num2str(data.pp.holeTrace.numberOfTargets)],'delimiter','','newline','pc','-append');
    dlmwrite([savePath_TFC,traceName,'.txt'],['Number of static portions: ' num2str(num_of_SP)],'delimiter','','newline','pc','-append');
    dlmwrite([savePath_TFC,traceName,'.txt'],'******-------------------------------------------------------------------------------------------------------------------****** ',...
        'delimiter','','newline','pc','-append');
    %% --------------------------------------------------------------------------
    
    for i= 1:data.pp.staticTraces.nbr_staticPortions
        ego_EFC= data.pp.staticTraces.(strcat('SP_',num2str(i))).EFC.ego;
        for j= 1:length(data.pp.staticTraces.(strcat('SP_',num2str(i))).relevantTargetsID)
            Id = data.pp.staticTraces.(strcat('SP_',num2str(i))).relevantTargetsID{j};
            target_EFC = data.pp.staticTraces.(strcat('SP_',num2str(i))).EFC.(Id);
            target_TFC = data.pp.staticTraces.(strcat('SP_',num2str(i))).TFC.(Id);
            %[isTargetRelevant,tj,label]=checkDataLabeling(target_EFC,target_TFC, Id, distance2holdingLine,saveLabelPath,traceName);
            data=checkDataLabeling(data,target_EFC,target_TFC, Id, distance2holdingLine,saveLabelPath,traceName);
            disp(['isTargetRelevant=', num2str(data.pp.targetsLabel.(Id).relevancy)]);
            disp (['tj =', num2str(data.pp.targetsLabel.(Id).tj)]);
            label=data.pp.targetsLabel.(Id).label;
            if (label==0)
                disp(['target label = ',num2str(label),' ; target is driving STRAIGHT']);
            elseif(label==1)
                disp(['target label = ',num2str(label),' ; target is TURNING']);
            else
                disp(['target label = ',num2str(label),' ; target is IRRELEVANT']);
            end
        end
    end
    
end
end

