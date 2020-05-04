% =========================================================================
%% class Scene_Analyzer_GUI_Model
%% Model class  used for start_gui
%% Defines all call back functions for managing the data
%%  Pushbutton   | Function
%%  Select_Trace | OpenFolder
%%  Run          | StartEvaluation
%%  Plot         | PlotData
%%  Label        | LabelTargets
%% Author: Bhagyaraj Dharmana, Automotive Safety Technologies GmbH, for AUDI AG, bhagyaraj.dharmana@astech-auto.de

%% =========================================================================
classdef Scene_Analyzer_GUI_Model < handle
    
    properties(SetObservable)      %%Variables to store globally
        data;
        path2data;
        path2scripts;
        labelPath;
        matlabFunctions;
        pythonFunctions;
        guiFunctions;
        tracename;
        Deploypath;
        TableData;
        probData;
        absolute_path;
        par;
        useEFC4Deploying;
        useTj4Deploying;
        modelFolderName;
        maxDataLength;
    end
    
    methods
        
        function this = Scene_Analyzer_GUI_Model(UserInput,par,useEFC4Deploying,useTj4Deploying,modelFolderName,maxDataLength)
            this.absolute_path =UserInput;
            this.par=par;
            this.useEFC4Deploying=useEFC4Deploying;
            this.useTj4Deploying=useTj4Deploying;
            this.modelFolderName=modelFolderName;
            this.maxDataLength=maxDataLength;
        end
        
        %--------------------------------------------------------------------------
        %% Function to select the trace from the directory
        %% ------------------------------------------------------------------------
        function OpenFolder(this, sGuiHandles)
            set(sGuiHandles.visualisation,'visible','off');
            set(sGuiHandles.data,'visible','off');
            set(sGuiHandles.individualTargets,'visible','off');
            set(sGuiHandles.labeledData,'visible','off');
            set(sGuiHandles.Trajectories,'visible','off');
            set(sGuiHandles.textAccuracy,'visible','off');
            cla(sGuiHandles.axespp);
            cla(sGuiHandles.axesorig);
            set(sGuiHandles.tableDeploy,'visible','off');
            set(sGuiHandles.tableDeploy,'data','');
            set(sGuiHandles.textProb, 'visible','off');
            %% Declare path
            %% ------------------------------------------------------------------------
            AbsolutePath= this.absolute_path;
            this.path2scripts=AbsolutePath;
            this.labelPath= [AbsolutePath,'\labeledData'];
            this.matlabFunctions=[this.path2scripts, '\functions\matlab'];
            this.pythonFunctions=[this.path2scripts, '\functions\python'];
            this.guiFunctions = [this.matlabFunctions, '\gui'];
            %--------------------------------------------------------------------------
            strDir = uigetdir('F:\kasTracesData_filtered\');
            %--------------------------------------------------------------------------
            [tracePath,traceName]=fileparts(strDir);
            this.path2data =tracePath;
            cd([this.guiFunctions])
            if ~strDir == 0
                this.tracename =traceName;
                set(sGuiHandles.texttracepath, 'String', strcat('Trace:',traceName));
            end
        end % openFolder
        %% ------------------------------------------------------------------------
        %% Function to Run the Globaol trajectory plots
        %% ------------------------------------------------------------------------
        function StartEvaluation(this, sGuiHandles)
            % fill Scene Data relevant parameters
            set(sGuiHandles.data,'visible','off');
            set(sGuiHandles.individualTargets,'visible','off');
            set(sGuiHandles.Trajectories,'visible','off');
            set(sGuiHandles.texttracepath,'visible','off');
            set(sGuiHandles.textAccuracy,'visible','off');
            set(sGuiHandles.labeledData,'visible','off');
            cla(sGuiHandles.axespp);
            cla(sGuiHandles.axesorig);
            set(sGuiHandles.visualisation,'visible','on');
            set(sGuiHandles.texttracepath, 'visible','on');
            axis_orig=sGuiHandles.axesorig;
            axis_pp=sGuiHandles.axespp;
            cd(this.matlabFunctions)
            dataStruct=labelingProcessSingleTrace(this.path2scripts,this.path2data,this.tracename,this.labelPath,this.par);
            cd(this.guiFunctions)
            this.data = dataStruct;
            legend('off')
            set(sGuiHandles.data,'visible','on');
            set(sGuiHandles.textSamplingTime, 'String', ['SamplingTime = ', num2str(dataStruct.par.samplingTime),' [s]']);
            set(sGuiHandles.textnooforigObj, 'String',  ['NbrOrigTargets = ', num2str(dataStruct.orig.numberOfTargets), ' [-]']);
            set(sGuiHandles.textnoofppObj, 'String', ['NbrPpTargets = ', num2str(dataStruct.pp.holeTrace.numberOfTargets), ' [-]']);
            set(sGuiHandles.textlengthofscene, 'String',['SceneLength = ', num2str(dataStruct.time(end)-dataStruct.time(1)), ' [s]']);
            set(sGuiHandles.textNoOfScenes, 'String', ['NbrStaticScenes = ', num2str(dataStruct.pp.staticTraces.nbr_staticPortions), ' [-]']);
            set(sGuiHandles.textminDist, 'String', ['MinTargetsDist = ', num2str(dataStruct.par.minDistBetwTargets), ' [m]']);
            set(sGuiHandles.textminegospeed, 'String', ['MinEgoSpeed = ', num2str(dataStruct.par.min_ego_speed),' [m/s]']);
            set(sGuiHandles.textDist2Holdingline, 'String',['DistToHoldingline = ', num2str(dataStruct.par.distance2holdingLine), ' [m]']);
            
            % read labeled data txt file
            finalTrajButtON=get(sGuiHandles.checkboxPropogate, 'Value');
            deployRNN_model= get(sGuiHandles.checkboxDeploy, 'Value');
            
            plotAndDeployTrainedModel(sGuiHandles,this,axis_orig,axis_pp,finalTrajButtON,deployRNN_model);
            
            % Visualize Individual Targets pannel
            set(sGuiHandles.individualTargets,'visible','on');
            options= fieldnames(dataStruct.pp.holeTrace.targets);
            set(sGuiHandles.popupmenuID,'String',options);
            cd(this.guiFunctions);
        end %StartEvaluation
        
        %% Function to select plot of individual targets in different coordinate systems
        %% ------------------------------------------------------------------------
        function plotIdSpecificData(this,sGuiHandles)
            caType  =  get(sGuiHandles.popupmenuID, 'String');
            idStr =  caType{get(sGuiHandles.popupmenuID, 'Value')};
            for kk=1:length(this.data.pp.holeTrace.targetsExistenceRange)
                if strcmp(this.data.pp.holeTrace.targetsExistenceRange{kk,1},idStr)
                    IDpos= kk;
                    break;
                end
            end
            timesamples = this.data.pp.holeTrace.targetsExistenceRange{IDpos,2};
            Target_Existence = [this.data.time(timesamples(1)) this.data.time(timesamples(2))];
            set(sGuiHandles.texttargetexistence, 'String', strcat('TargetExistenceRange [s] = [', num2str(Target_Existence),']'));
            set(sGuiHandles.Trajectories,'visible','on')
            ca1Type =  get(sGuiHandles.popupmenucoordinatestype, 'String');
            cordType =  ca1Type{get(sGuiHandles.popupmenucoordinatestype, 'Value')};
            %---------------------
            % condition for global
            %---------------------
            if(this.data.pp.targetsLabel.(idStr).relevancy ~=-1)
                plotIndividualIdData(sGuiHandles,this.data,idStr, cordType);
            else
                set(sGuiHandles.Trajectories,'visible','off');
            end
            
            % show label data
            set(sGuiHandles.labeledData,'visible','on');
            selectedID  =  get(sGuiHandles.popupmenuID, 'String');
            idVal =  selectedID{get(sGuiHandles.popupmenuID, 'Value')};
            set(sGuiHandles.textTargetID, 'String',['Target ID: ', idVal]);
            set(sGuiHandles.textRelevancy, 'String',['Relevancy: ', num2str(this.data.pp.targetsLabel.(idVal).relevancy)]);
            set(sGuiHandles.texttj, 'String',['tj= ',num2str(this.data.pp.targetsLabel.(idVal).tj)]);
            set(sGuiHandles.textLabel, 'String',['Label= ',num2str(this.data.pp.targetsLabel.(idVal).label)]);
            set(sGuiHandles.textComment, 'String',['Comment: ',this.data.pp.targetsLabel.(idVal).comment]);
            % if deploy model show the specific prob. of going straight
            deployRNN_model= get(sGuiHandles.checkboxDeploy, 'Value');
            if (deployRNN_model)
                for k= 1: size(this.TableData,1)
                    if strcmp(this.TableData{k,1},idVal)
                        Index=k;
                    end
                end
                set(sGuiHandles.textProb, 'visible','on');
                if ~ isempty(this.TableData)
                    set(sGuiHandles.textProb, 'String',['Probability: [',this.TableData{Index,2},', ',this.TableData{Index,3},']']);
                else
                    set(sGuiHandles.textProb, 'String','Probability: [X , X]');
                end
            end
        end %Plotdata
    end
end %Scene_Analyzer_GUI_Model