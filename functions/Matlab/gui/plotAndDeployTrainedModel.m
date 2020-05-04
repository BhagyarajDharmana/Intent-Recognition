function plotAndDeployTrainedModel(h,this,axis_orig,axis_pp,finalTrajButtON,deployRNN_model)
%----------------
colIdx_xpos01     = 1;
colIdx_ypos01     = 2;
colIdx_yaw01      = 7;
%----------------
data=this.data;
tracename=this.tracename;
labelPath=this.labelPath;
python_path=this.pythonFunctions;
matlab_path=this.matlabFunctions;
%----------------
egoData=data.egoData;
egoPosx= egoData(:,2);
egoPosy=egoData(:,3);
egoYaw= egoData(:,8);
%----------------
targetData=data.orig.targetsData;
targetsRanges=cell2mat(data.orig.targetsExistenceRange(:,2));
firstTargetEntry=min(targetsRanges(:,1));
lastTargetExit=max(targetsRanges(:,2));
startPlotTimestamp=firstTargetEntry;
endPlotTimeStamp=lastTargetExit;
numberOfTargets=data.orig.numberOfTargets;
idIndices=data.orig.idIndices;
timestamps=targetData(:,1);
%----------------
minXpos=min(egoPosx);
maxXpos=max(egoPosx);
minYpos=min(egoPosy);
maxYpos=max(egoPosy);
for obj = 1:numberOfTargets
    minXpos=min(minXpos,min(targetData(:,colIdx_xpos01+idIndices(obj))));
    maxXpos=max(maxXpos,max(targetData(:,colIdx_xpos01+idIndices(obj))));
    minYpos=min(minYpos,min(targetData(:,colIdx_ypos01+idIndices(obj))));
    maxYpos=max(maxYpos,max(targetData(:,colIdx_ypos01+idIndices(obj))));
end
%----------------
targetsStr=data.orig.targetsStr;
colors=data.orig.targetsColors;
pptargetsStr=data.pp.holeTrace.pptragetsStr;
ppcolors=data.pp.holeTrace.pptargetsColors;
pptargetsID=data.pp.holeTrace.targetsExistenceRange(:,1);
%----------------
coef=0.1;
deltaX=coef/2*(maxXpos-minXpos);
deltaY=coef/2*(maxYpos-minYpos);
axes(axis_orig);
cd(this.matlabFunctions)
plotVehicle([egoPosx(endPlotTimeStamp),egoPosy(endPlotTimeStamp)],egoYaw(endPlotTimeStamp));
hold on;
h1_orig=plot(egoPosx(1:endPlotTimeStamp),egoPosy(1:endPlotTimeStamp),'g');
axis([minXpos-deltaX maxXpos+deltaX minYpos-deltaY (maxYpos+deltaY)]);
for obj = 1:numberOfTargets
    tentry=data.orig.targetsExistenceRange{obj,2}(1);
    texit=data.orig.targetsExistenceRange{obj,2}(2);
    if (endPlotTimeStamp>=tentry && endPlotTimeStamp<texit)
        plotVehicle([targetData(endPlotTimeStamp,colIdx_xpos01+idIndices(obj)),targetData(endPlotTimeStamp,colIdx_ypos01+idIndices(obj))],targetData(endPlotTimeStamp,colIdx_yaw01+idIndices(obj)),colors(:,obj)');
        hold on;
        plot(targetData(tentry:endPlotTimeStamp,colIdx_xpos01+idIndices(obj)),targetData(tentry:endPlotTimeStamp,colIdx_ypos01+idIndices(obj)),'Color',colors(:,obj),'LineWidth',2);
    elseif (endPlotTimeStamp>=texit)
        plotVehicle([targetData(texit,colIdx_xpos01+idIndices(obj)),targetData(texit,colIdx_ypos01+idIndices(obj))],targetData(texit,colIdx_yaw01+idIndices(obj)),colors(:,obj)');
        hold on;
        h2_orig(obj)=plot(targetData(tentry:texit,colIdx_xpos01+idIndices(obj)),targetData(tentry:texit,colIdx_ypos01+idIndices(obj)),'Color',colors(:,obj),'LineWidth',2);
    end
end
legend([h1_orig h2_orig],['EGO',targetsStr]);
title('Trajectories Visualization of Original-Data');
xlabel('East [m]');
ylabel('North [m]');
axes(axis_pp);

% if deploy model calc. probabilities
if(deployRNN_model)
    if(this.useEFC4Deploying)
        tmp='\EFC\';
    else
        tmp='\TFC\';
    end
    labelTxtPath = [labelPath,tmp,tracename,'.txt'];
    cd(python_path)
    if (this.useTj4Deploying)
        considerTj=1;
    else
        considerTj=0;
    end
    delete *.mat;
    modelFolderPath=[this.absolute_path,'\trainedModels\',this.modelFolderName];
    command=['python deployLstmModel.py --labelTxtPath ',labelTxtPath,' --considerTj ', num2str(considerTj),...
        ' --modelFolderPath ', modelFolderPath, ' --maxDataLength ', num2str(this.maxDataLength)];
    system(command);
    if (exist('prob.mat','file')~=0)
        prob=load('prob.mat');
        relIDs=load('IDs.mat');
        prob=prob.prob;
        relIDs=relIDs.IDs;
        this.TableData= [];
        for i =1:this.data.pp.holeTrace.numberOfTargets
            ID = this.data.pp.holeTrace.targetsExistenceRange{i,1};
            label=this.data.pp.targetsLabel.(ID).label;
            probstrt = 'X';
            probturn = 'X';
            for jj=1:size(relIDs)
                currRelID=strrep(relIDs(jj,:),' ','');
                if strcmp(currRelID,ID)
                    if size(prob,2)==2
                    probstrt=num2str(prob(jj,1));
                    probturn=num2str(prob(jj,2));
                    else
                    probstrt=num2str(1-prob(jj));
                    probturn=num2str(prob(jj));
                    end
                    break;
                end
            end
            if label==0
                labelStr='Straight';
                
            elseif label ==1
                labelStr='Turning';
            else
                labelStr='Irrelevant';
            end
            this.TableData{i,1}= ID;
            this.TableData{i,2}= probstrt;
            this.TableData{i,3}= probturn;
            this.TableData{i,4}= labelStr;
        end
        set(h.tableDeploy,'visible','on');
        set(h.tableDeploy,'data',cell(this.data.pp.holeTrace.numberOfTargets,4));
        set(h.tableDeploy,'ColumnName',{'ID';'probStr';'probTurn';'label'});
        set(h.tableDeploy,'data',this.TableData);
        delete *.mat;
        % adapt table dimension
        axesDim=get(axis_pp,'Position');
        table_x0=0.78;
        table_w=0.22;
        table_h=0.039*(this.data.pp.holeTrace.numberOfTargets+1);
        if (table_h>0.85)
            table_h=0.85;
        end
        table_y0=(axesDim(2)+axesDim(4))-table_h;
        set(h.tableDeploy,'Position',[table_x0 table_y0 table_w table_h]);
        % calc. prediction accuracy and show it in the text box
        nbrofrelTargets =0;
        nbrofTrueLabels =0;
        nbrofFalseLabels = 0;
        for i= 1: size(this.TableData,1)
            if ~ strcmp(this.TableData{i,4},'Irrelevant')
                nbrofrelTargets= nbrofrelTargets+1;
                if (str2double(this.TableData{i,2}) >=0.5 && isequal(this.TableData{i,4},'Straight')) || ...
                        (str2double(this.TableData{i,3}) >=0.5 && isequal(this.TableData{i,4},'Turning'))
                    nbrofTrueLabels = nbrofTrueLabels+1;
                else
                    nbrofFalseLabels=nbrofFalseLabels+1;
                end
                
            end
        end
        set(h.textAccuracy,'visible','on');
        if (nbrofrelTargets==0)
            set(h.textAccuracy,'String','Accuracy = N.R.');
        else
            Accuracy = (nbrofTrueLabels/nbrofrelTargets)*100;
            set(h.textAccuracy,'String',['Accuracy = ',num2str(Accuracy), ' %']);
        end
        if Accuracy<50
            set(h.textAccuracy,'ForegroundColor','r');
        else
            set(h.textAccuracy,'ForegroundColor','g');
        end
        % adapt text box dimension
        txtDim=get(h.textAccuracy, 'Position');
        x0_txt=(table_x0+table_w)-txtDim(3);
        y0_txt=table_y0-txtDim(4)-0.02;
        set(h.textAccuracy, 'Position',[x0_txt y0_txt txtDim(3) txtDim(4)]);
    else
        set(h.textAccuracy,'visible','on');
        set(h.textAccuracy,'String','No existing Targets with enough Data!!');
        txtDim=get(h.textAccuracy, 'Position');
        axesDim=get(axis_pp,'Position');
        set(h.textAccuracy, 'Position',[axesDim(1)+axesDim(3), axesDim(2)+0.5*(axesDim(4)-txtDim(4)), txtDim(3), txtDim(4)]);
        set(h.textAccuracy,'FontSize',9);
        set(h.textAccuracy,'ForegroundColor','r');
    end
end
cd(matlab_path);
% plot pp DATA trajectory
if (finalTrajButtON)
    plotVehicle([egoPosx(endPlotTimeStamp),egoPosy(endPlotTimeStamp)],egoYaw(endPlotTimeStamp));
    hold on;
    h1_pp=plot(egoPosx(1:endPlotTimeStamp),egoPosy(1:endPlotTimeStamp),'g');
    axis([minXpos-deltaX maxXpos+deltaX minYpos-deltaY (maxYpos+deltaY)]);
    for obj = 1:data.pp.holeTrace.numberOfTargets
        tentry=data.pp.holeTrace.targetsExistenceRange{obj,2}(1);
        texit=data.pp.holeTrace.targetsExistenceRange{obj,2}(2);
        idx=find(timestamps(endPlotTimeStamp)==data.pp.holeTrace.targets.(pptargetsID{obj})(:,1),1);
        if (endPlotTimeStamp>=tentry && endPlotTimeStamp<texit)
            plotVehicle([data.pp.holeTrace.targets.(pptargetsID{obj})(idx,2),data.pp.holeTrace.targets.(pptargetsID{obj})(idx,3)],data.pp.holeTrace.targets.(pptargetsID{obj})(idx,end-1),ppcolors(:,obj)');
            hold on;
            plot(data.pp.holeTrace.targets.(pptargetsID{obj})(1:idx,2),data.pp.holeTrace.targets.(pptargetsID{obj})(1:idx,3),'Color',ppcolors(:,obj),'LineWidth',2);
        elseif (endPlotTimeStamp>=texit)
            plotVehicle([data.pp.holeTrace.targets.(pptargetsID{obj})(end,2),data.pp.holeTrace.targets.(pptargetsID{obj})(end,3)],data.pp.holeTrace.targets.(pptargetsID{obj})(end,end-1),ppcolors(:,obj)');
            hold on;
            h2_pp(obj)=plot(data.pp.holeTrace.targets.(pptargetsID{obj})(:,2),data.pp.holeTrace.targets.(pptargetsID{obj})(:,3),'Color',ppcolors(:,obj),'LineWidth',2);
        end
        text(axis_pp,minXpos,maxYpos,['t= ',num2str(this.data.time(endPlotTimeStamp)),' s']);
    end
    
else
    for i =startPlotTimestamp:endPlotTimeStamp
        curr_t=this.data.time(i);
        plotVehicle([egoPosx(i),egoPosy(i)],egoYaw(i));
        hold on;
        h1_pp=plot(egoPosx(1:i),egoPosy(1:i),'g');
        axis([minXpos-deltaX maxXpos+deltaX minYpos-deltaY (maxYpos+deltaY)]);
        for obj = 1:data.pp.holeTrace.numberOfTargets
            tentry=data.pp.holeTrace.targetsExistenceRange{obj,2}(1);
            texit=data.pp.holeTrace.targetsExistenceRange{obj,2}(2);
            idx=find(timestamps(i)==data.pp.holeTrace.targets.(pptargetsID{obj})(:,1),1);
            if (i>=tentry && i<texit)
                plotVehicle([data.pp.holeTrace.targets.(pptargetsID{obj})(idx,2),data.pp.holeTrace.targets.(pptargetsID{obj})(idx,3)],data.pp.holeTrace.targets.(pptargetsID{obj})(idx,end-1),ppcolors(:,obj)');
                hold on;
                plot(data.pp.holeTrace.targets.(pptargetsID{obj})(1:idx,2),data.pp.holeTrace.targets.(pptargetsID{obj})(1:idx,3),'Color',ppcolors(:,obj),'LineWidth',2);
            elseif (i>=texit)
                plotVehicle([data.pp.holeTrace.targets.(pptargetsID{obj})(end,2),data.pp.holeTrace.targets.(pptargetsID{obj})(end,3)],data.pp.holeTrace.targets.(pptargetsID{obj})(end,end-1),ppcolors(:,obj)');
                hold on;
                h2_pp(obj)=plot(data.pp.holeTrace.targets.(pptargetsID{obj})(:,2),data.pp.holeTrace.targets.(pptargetsID{obj})(:,3),'Color',ppcolors(:,obj),'LineWidth',2);
            end
        end
        text(axis_pp,minXpos,maxYpos,['t= ',num2str(curr_t),' s']);
        pause(0.025);
        if i ~= endPlotTimeStamp
            cla;
        end
    end
end
% Plot the holdingLine crossing point for all relevant IDs
for obj = 1:data.pp.holeTrace.numberOfTargets
    ID =data.pp.holeTrace.targetsExistenceRange{obj,1};
    if (data.pp.targetsLabel.(ID).relevancy==1)
        tj= data.pp.targetsLabel.(ID).tj;
        tjTimestamp=find(data.pp.holeTrace.targets.(ID)(:,1)>=tj,1);
        xposAtTj = data.pp.holeTrace.targets.(ID)(tjTimestamp,2);
        yposAtTj = data.pp.holeTrace.targets.(ID)(tjTimestamp,3);
        plot(xposAtTj,yposAtTj,'--gs', 'LineWidth',2,'MarkerSize',5,'MarkerEdgeColor','g',...
            'MarkerFaceColor','g');
    end
end
legend('on')
legend([h1_pp h2_pp],['EGO',pptargetsStr]);
xlabel('East [m]');
ylabel('North [m]');
title('Trajectories Visualization of Processed-Data');
hold off;
end