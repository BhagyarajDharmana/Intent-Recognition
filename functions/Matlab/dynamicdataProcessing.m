%=================================================================================================================================
%% Function for preprocessing Ego and targets Data and visualisation.  %%
%% Run this function before starting the labeling process of the scene. %%
%% Author: Bilel Said (AST-42)
%% Date  : 14.01.2019
%% Input arguments are:
%   tracePath                : the absolute path of the trace
%   traceName                : Name of the specific trace folder
%   plotData                 : 0 -> don't plot trajectory data/ 1 -> plot Original trajectory Data/ 2 -> plot postprocessed Data
%   minDistBetwTargets       : minimum distance ( in m) between a projected target and an existing one to separate them as 2 physical targets
%   minTargetExistTimeStamps : Minimum Number of timestamps to consider a processed Target
%   saveProcessedData        : boolean, true if user want to save processed objects dynamic data in xlsx sheets
%% Output argument is:
%   data                     : a struct containing ego and targets original and processed dynamic data as well as their existence ranges in the scene
%=================================================================================================================================
function data= dynamicdataProcessing(tracesPath, traceName,plotData,minDistBetwTargets,minTargetExistTimeStamps,saveProcessedData)
%--------------------------------------------------------------------------
%% Paths declaration
%--------------------------------------------------------------------------
pathToData = fullfile(tracesPath, traceName);
savePath=pathToData;
egoGlobalTrajSuffix='_GlobalTrajectory_Ego_sdf.csv';
targetsGlobalTrajSuffix='_GlobalTrajectory_TargetSortedID_sdf.csv';
addpath(pathToData);
%--------------------------------------------------------------------------
%% Declaration of relevant constants
%--------------------------------------------------------------------------
samplingTime = 0.04;                                                       % in [s]
colIdx_xpos01     = 1;
colIdx_ypos01     = 2;
colIdx_velx01     = 3;
colIdx_vely01     = 4;
colIdx_accx01     = 5;
colIdx_accy01     = 6;
colIdx_yaw01      = 7;
colIdx_yawRrate01 = 8;
%--------------------------------------------------------------------------
%% Read Ego and target Data from Excel sheets
%--------------------------------------------------------------------------
sepLine='--------------------------------------------------------------------------';
disp(sepLine);
disp('STEP 1, READ ORIGINAL DATA:');
disp(sepLine);
egoDataStruct = importdata([traceName egoGlobalTrajSuffix]);
targetDataStruct = importdata([traceName  targetsGlobalTrajSuffix]);
egoData=egoDataStruct.data;
targetData = targetDataStruct.data;
textData = [targetDataStruct.textdata(1)   targetDataStruct.textdata(1,3:10)];
targetDataFirstRow= targetDataStruct.textdata;                             %text data in the first row of the excel sheet of targets.
indices = cellfun(@(x) strfind(x,'ID'), targetDataFirstRow, 'UniformOutput', false);
idIndices = find(~cellfun(@isempty,indices));
% delete ID if is only NAN or id is a big number
for zz=1:length(idIndices)
    id_startCol = idIndices(zz);
    if (zz==length(idIndices))
        id_endCol = size(targetData,2);
    else
        id_endCol= idIndices(zz+1)-1;
    end
    kk=1;
    id=targetData(kk,id_startCol);
    while (isnan(id)&& kk<=size(targetData,1))
        id=targetData(kk,id_startCol);
        kk=kk+1;
    end
    if (isnan(id)|| (id>1e07))
        targetData(:,id_startCol:id_endCol)=[];
        idIndices(end)=[];
    end
end
numberOfTargets = length(idIndices);
m_EgoData=size(egoData,1);
m_TargetData=size(targetData,1);
timestamps=targetData(:,1);
%--------------------------------------------------------------------------
data.par.samplingTime=samplingTime;
data.par.minDistBetwTargets=minDistBetwTargets;
data.par.minTargetExistTimeStamps=minTargetExistTimeStamps;
data.orig.numberOfTargets=numberOfTargets;
data.orig.targetsData=targetData;
data.time=timestamps;
data.egoData=egoData;
data.orig.idIndices=idIndices;
disp(['length of the scene: T = ' num2str(timestamps(m_TargetData)) ' s']);
disp(['Original Number of Targets: ' num2str(data.orig.numberOfTargets) ]);
%--------------------------------------------------------------------------
egoPosx     = egoData(:,2);
egoPosy     = egoData(:,3);
egoVelx     = egoData(:,4);
egoVely     = egoData(:,5);
egoAccx     = egoData(:,6);
egoAccy     = egoData(:,7);
egoYaw      = egoData(:,8);
egoYawRate  = egoData(:,9);
%--------------------------------------------------------------------------
%% Find the entry and exit time of targets(ID's)
%--------------------------------------------------------------------------
colors=zeros(3,numberOfTargets);
targetsStr=[];
maxID=0;
for obj = 1:numberOfTargets
    targetID = targetData(:,idIndices(obj));
    for kk=1:m_TargetData
        if ~isnan(targetID(kk))
            tentry=kk;
            break;
        end
    end
    for kk=m_TargetData:-1:tentry
        if ~isnan(targetID(kk))
            texit=kk;
            break;
        end
    end
    id=targetID(tentry);
    if id<=9
        idStr=['0' num2str(id)];
    else
        idStr=num2str(id);
    end
    data.orig.targetsExistenceRange{obj,1}=['ID' idStr];
    data.orig.targetsExistenceRange{obj,2}=[tentry texit];
    maxID=max(maxID,max(targetID));
end
%--------------------------------------------------------------------------
% Get Target-IDs as strings
%--------------------------------------------------------------------------
for obj = 1:numberOfTargets
    tentry=data.orig.targetsExistenceRange{obj,2}(1);
    id = targetData(tentry,idIndices(obj));
    if id<=9
        idStr=['0' num2str(id)];
    else
        idStr=num2str(id);
    end
    targetsStr{obj}=['TargetID' idStr];
    colors(:,obj)=rand(3,1);
end
%--------------------------------------------------------------------------
% Determine the timestamp where the first Target appears in the scene
% and where the last one disappears
%--------------------------------------------------------------------------
firstTargetEntry=m_TargetData;
lastTargetExit=1;
for ii = 1:numberOfTargets
    firstTargetEntry=min(firstTargetEntry,data.orig.targetsExistenceRange{ii,2}(1));
    lastTargetExit=max(lastTargetExit,data.orig.targetsExistenceRange{ii,2}(2));
end
%--------------------------------------------------------------------------
%% interpolate possible Targets-data Gaps
%--------------------------------------------------------------------------
disp(sepLine);
disp('STEP 2, INTERPOLATE POSSIBLE DATA GAPS: ');
disp(sepLine);
projectedPos=@(deltaT,xy,v_xy,a_xy) a_xy*(deltaT^2/2)+v_xy*deltaT+xy;
newID=maxID;
for obj=1:numberOfTargets
    disp(['********** Interpolation for Target' data.orig.targetsExistenceRange{obj,1} ' **********']);
    X0=[];
    X1=[];
    tentry=data.orig.targetsExistenceRange{obj,2}(1);
    texit=data.orig.targetsExistenceRange{obj,2}(2);
    targetID = targetData(:,idIndices(obj));
    xpos=targetData(:,colIdx_xpos01+idIndices(obj));
    ypos=targetData(:,colIdx_ypos01+idIndices(obj));
    vx=targetData(:,colIdx_velx01+idIndices(obj));
    vy=targetData(:,colIdx_vely01+idIndices(obj));
    ax=targetData(:,colIdx_accx01+idIndices(obj));
    ay=targetData(:,colIdx_accy01+idIndices(obj));
    yaw=targetData(:,colIdx_yaw01+idIndices(obj));
    yawRate=targetData(:,colIdx_yawRrate01+idIndices(obj));
    currentID=targetID(tentry);
    nanFlag=true;
    isDataGap=false;
    for kk=tentry:texit
        if isnan(targetID(kk))&& nanFlag
            X0=[X0;xpos(kk-1),ypos(kk-1),vx(kk-1),vy(kk-1),ax(kk-1),ay(kk-1),yaw(kk-1),yawRate(kk-1),kk-1];
            nanFlag=false;
            isDataGap=true;
        end
        if isDataGap && ~isnan(targetID(kk))
            X1=[X1;xpos(kk),ypos(kk),vx(kk),vy(kk),ax(kk),ay(kk),yaw(kk),yawRate(kk),kk];
            nanFlag=true;
            isDataGap=false;
        end
    end
    for j=1:size(X0,1)
        deltaT=data.par.samplingTime*(X1(j,9)-X0(j,9));
        projectedX=projectedPos(deltaT,X0(j,1),X0(j,3),X0(j,5));
        projectedY=projectedPos(deltaT,X0(j,2),X0(j,4),X0(j,6));
        dist=sqrt((projectedX-X1(j,1))^2+(projectedY-X1(j,2))^2);
        if (dist<=minDistBetwTargets)
            if max(isnan(X1(j,3:4)))
                X=linearInterpolation([X0(j,1),timestamps(X0(j,end))],[X1(j,1),timestamps(X1(j,end))], timestamps);
                Y=linearInterpolation([X0(j,2),timestamps(X0(j,end))],[X1(j,2),timestamps(X1(j,end))], timestamps);
                if (isnan(X1(j,3)))
                    VX=X0(j,3)*ones(size(X,1),1);
                else
                    VX=linearInterpolation([X0(j,3),timestamps(X0(j,end))],[X1(j,3),timestamps(X1(j,end))], timestamps);
                end
                if (isnan(X1(j,4)))
                    VY=X0(j,4)*ones(size(X,1),1);
                else
                    VY=linearInterpolation([X0(j,4),timestamps(X0(j,end))],[X1(j,4),timestamps(X1(j,end))], timestamps);
                end
                OUT=[X Y VX VY];
                str2disp='using linear interpolation because Vx and/or Vy in timestamp n2 is/are NAN.';
            else
                OUT = cubicInterpolation([X0(j,1:4),timestamps(X0(j,end))],[X1(j,1:4),timestamps(X1(j,end))],timestamps);
                str2disp='using cubic interpolation (for position and velocity) and linear interpolation for the rest.';
            end
            AX= linearInterpolation([X0(j,5),timestamps(X0(j,end))],[X1(j,5),timestamps(X1(j,end))], timestamps);
            AY= linearInterpolation([X0(j,6),timestamps(X0(j,end))],[X1(j,6),timestamps(X1(j,end))], timestamps);
            YAW= linearInterpolation([X0(j,7),timestamps(X0(j,end))],[X1(j,7),timestamps(X1(j,end))], timestamps);
            YAWRATE=linearInterpolation([X0(j,8),timestamps(X0(j,end))],[X1(j,8),timestamps(X1(j,end))], timestamps);
            targetData(X0(j,end)+1:X1(j,end)-1,idIndices(obj))=currentID*ones(size(OUT,1),1);
            targetData(X0(j,end)+1:X1(j,end)-1,(colIdx_xpos01:colIdx_vely01)+idIndices(obj))=OUT(:,1:4);
            targetData(X0(j,end)+1:X1(j,end)-1,(colIdx_accx01:colIdx_yawRrate01)+idIndices(obj))=[AX AY YAW YAWRATE];
            disp(['[+] Data Gap between the timestamps: n1 = ' num2str(X0(j,end)) ' and n2 = ' num2str(X1(j,end)) ' is interpolated ' str2disp]);
        else
            newID=newID+1;
            currentID=newID;
            for ii=X1(j,end):texit
                if ~isnan(targetData(ii,idIndices(obj)))
                    targetData(ii,idIndices(obj))=newID;
                end
            end
            if isnan(dist)
                str2disp='NAN values in the state vector of timestamp n1.';
            else
                str2disp=['distance between projected state vector of timestamp n1 and state vector of n2 (dist = ' num2str(dist) ') is greater than minDistBetwTargets = ' num2str(minDistBetwTargets) '.'];
            end
            disp(['[-] Data Gap between the timestamps: n1 = ' num2str(X0(j,end)) ' and n2 = ' num2str(X1(j,end)) ' can NOT be interpolated due to: ' str2disp]);
            disp (['    --> New Target with ID ' num2str(newID) ' will be created']);
        end
    end
    if (size(X0,1)<1)
        disp('No Data Gap  was found for this ID.')
    end
end
if (newID>maxID)
    disp (['  ==> After the interpolation Step, ' num2str(newID-maxID) ' new Targets have been defined. '])
else
    disp ('  ==> After the interpolation step, NO new Targets have been defined.')
end

%--------------------------------------------------------------------------
%% Save interpolated Data
%--------------------------------------------------------------------------
data.pp.holeTrace.targets=[];                                                        %Targets.IDXX: t,x,y,vx,vy,accx,accy,yaw,yawRate
for obj=1:numberOfTargets
    idNum=Inf;
    tentry=data.orig.targetsExistenceRange{obj,2}(1);
    texit=data.orig.targetsExistenceRange{obj,2}(2);
    targetID = targetData(:,idIndices(obj));
    for ii=tentry:texit
        if ~isnan(targetID(ii))
            if idNum ~= targetID(ii)
                idNum=targetID(ii);
                if idNum<10
                    ID= ['0' num2str(idNum)];
                else
                    ID= num2str(idNum);
                end
                idStr=['ID' ID];
                data.pp.holeTrace.targets.(idStr)=[];
            end
            dataRow=[timestamps(ii),targetData(ii,(colIdx_xpos01:colIdx_yawRrate01)+idIndices(obj))];
            data.pp.holeTrace.targets.(idStr)=[data.pp.holeTrace.targets.(idStr); dataRow];
        end
    end
end
if isempty(data.pp.holeTrace.targets)
    data.pp.holeTrace.numberOfTargets=0;
    data.pp.holeTrace.targetsExistenceRange=[];
else
    data.pp.holeTrace.numberOfTargets=length(fieldnames(data.pp.holeTrace.targets));
    pptargetsID=fieldnames(data.pp.holeTrace.targets);
    for obj=1:data.pp.holeTrace.numberOfTargets
        data.pp.holeTrace.targetsExistenceRange{obj,1}=pptargetsID{obj};
        data.pp.holeTrace.targetsExistenceRange{obj,2}=[find(timestamps==data.pp.holeTrace.targets.(pptargetsID{obj})(1,1),1) find(timestamps==data.pp.holeTrace.targets.(pptargetsID{obj})(end,1),1)];
    end
    
    %--------------------------------------------------------------------------
    %% filtering out targets (physical targets) with different IDs
    %--------------------------------------------------------------------------
    disp(sepLine);
    disp('STEP 3, FILTERING OUT PHYSICAL TARGETS:');
    disp(sepLine);
    n=data.pp.holeTrace.numberOfTargets;
    ii=1;
    while ii<=n   %for ii=1:data.pp.holeTrace.numberOfTargets  %-1
        pptargetsID=data.pp.holeTrace.targetsExistenceRange(:,1);
        jj=1;
        while jj<=n    %for jj=setdiff(1:data.pp.holeTrace.numberOfTargets,ii)                       %=ii:data.pp.holeTrace.numberOfTargets
            if (jj==ii)
                if (jj==n)
                    break;
                else
                    jj=jj+1;
                end
            end
            texitOld=data.pp.holeTrace.targets.(pptargetsID{ii})(end,1);
            tentryNew=data.pp.holeTrace.targets.(pptargetsID{jj})(1,1);
            if (tentryNew>texitOld)
                deltaT=tentryNew-texitOld;
                xposNew=data.pp.holeTrace.targets.(pptargetsID{jj})(1,2);
                yposNew=data.pp.holeTrace.targets.(pptargetsID{jj})(1,3);
                projectedX=projectedPos(deltaT,data.pp.holeTrace.targets.(pptargetsID{ii})(end,2),data.pp.holeTrace.targets.(pptargetsID{ii})(end,4),data.pp.holeTrace.targets.(pptargetsID{ii})(end,6));
                projectedY=projectedPos(deltaT,data.pp.holeTrace.targets.(pptargetsID{ii})(end,3),data.pp.holeTrace.targets.(pptargetsID{ii})(end,5),data.pp.holeTrace.targets.(pptargetsID{ii})(end,7));
                dist=sqrt((projectedX-xposNew)^2+(projectedY-yposNew)^2);
                if (dist<=minDistBetwTargets)                                  % interpolation
                    %-----
                    if max(isnan(data.pp.holeTrace.targets.(pptargetsID{jj})(1,4:5)))
                        X=linearInterpolation([data.pp.holeTrace.targets.(pptargetsID{ii})(end,2),texitOld],[data.pp.holeTrace.targets.(pptargetsID{jj})(1,2),tentryNew], timestamps);
                        Y=linearInterpolation([data.pp.holeTrace.targets.(pptargetsID{ii})(end,3),texitOld],[data.pp.holeTrace.targets.(pptargetsID{jj})(1,3),tentryNew], timestamps);
                        if (isnan(data.pp.holeTrace.targets.(pptargetsID{jj})(1,4)))
                            VX=(data.pp.holeTrace.targets.(pptargetsID{ii})(end,4))*ones(size(X,1),1);
                        else
                            VX=linearInterpolation([data.pp.holeTrace.targets.(pptargetsID{ii})(end,4),texitOld],[data.pp.holeTrace.targets.(pptargetsID{jj})(1,4),tentryNew], timestamps);
                        end
                        if (isnan(data.pp.holeTrace.targets.(pptargetsID{jj})(1,5)))
                            VY=(data.pp.holeTrace.targets.(pptargetsID{ii})(end,5))*ones(size(X,1),1);
                        else
                            VY=linearInterpolation([data.pp.holeTrace.targets.(pptargetsID{ii})(end,5),texitOld],[data.pp.holeTrace.targets.(pptargetsID{jj})(1,5),tentryNew], timestamps);
                        end
                        OUT=[X Y VX VY];
                        str2disp='using linear interpolation because Vx and/or Vy in timestamp n2 is/are NAN.';
                    else
                        OUT = cubicInterpolation([data.pp.holeTrace.targets.(pptargetsID{ii})(end,2:5),texitOld],[data.pp.holeTrace.targets.(pptargetsID{jj})(1,2:5),tentryNew],timestamps);
                        str2disp='using cubic interpolation (for position and velocity) and linear interpolation for the rest.';
                    end
                    AX= linearInterpolation([data.pp.holeTrace.targets.(pptargetsID{ii})(end,6),texitOld],[data.pp.holeTrace.targets.(pptargetsID{jj})(1,6),tentryNew], timestamps);
                    AY= linearInterpolation([data.pp.holeTrace.targets.(pptargetsID{ii})(end,7),texitOld],[data.pp.holeTrace.targets.(pptargetsID{jj})(1,7),tentryNew], timestamps);
                    YAW= linearInterpolation([data.pp.holeTrace.targets.(pptargetsID{ii})(end,8),texitOld],[data.pp.holeTrace.targets.(pptargetsID{jj})(1,8),tentryNew], timestamps);
                    YAWRATE=linearInterpolation([data.pp.holeTrace.targets.(pptargetsID{ii})(end,9),texitOld],[data.pp.holeTrace.targets.(pptargetsID{jj})(1,9),tentryNew], timestamps);
                    data.pp.holeTrace.numberOfTargets=data.pp.holeTrace.numberOfTargets-1;
                    n=n-1;
                    mat2add=[timestamps(find(timestamps==texitOld,1)+1:find(timestamps==tentryNew,1)-1) ,OUT(:,1:4), AX,AY,YAW,YAWRATE];
                    %mat2add=[((texitOld+data.par.samplingTime):data.par.samplingTime:(tentryNew-data.par.samplingTime))' ,OUT(:,1:4), AX,AY,YAW,YAWRATE];
                    if size(OUT,1)>=1
                        data.pp.holeTrace.targets.(pptargetsID{ii})=[data.pp.holeTrace.targets.(pptargetsID{ii});mat2add;data.pp.holeTrace.targets.(pptargetsID{jj})];
                    else
                        data.pp.holeTrace.targets.(pptargetsID{ii})=[data.pp.holeTrace.targets.(pptargetsID{ii});data.pp.holeTrace.targets.(pptargetsID{jj})];
                    end
                    data.pp.holeTrace.targetsExistenceRange{ii,2}(2)=data.pp.holeTrace.targetsExistenceRange{jj,2}(2);
                    data.pp.holeTrace.targetsExistenceRange(jj,:)=[];
                    data.pp.holeTrace.targets=rmfield(data.pp.holeTrace.targets,pptargetsID{jj});
                    disp(['Targets with ID ' pptargetsID{ii} ' and ID ' pptargetsID{jj} ' are interpolated, ' str2disp  ' Then Target ' pptargetsID{jj} ' was deleted.']);
                    if (ii>jj)
                        ii=ii-1;
                    end
                end
            end
            pptargetsID=data.pp.holeTrace.targetsExistenceRange(:,1);
            jj=jj+1;
        end
        ii=ii+1;
    end
    
    if (data.pp.holeTrace.numberOfTargets<(data.orig.numberOfTargets+newID-maxID))
        disp (['  ==> After the Filtering Step, ' num2str(data.orig.numberOfTargets+newID-maxID-data.pp.holeTrace.numberOfTargets) ' Targets have been deleted.']);
    else
        disp('No interpolation between different Target IDs have been done')
        disp ('  ==> After the Filtering Step, NO Targets have been deleted.');
    end
    %--------------------------------------------------------------------------
    %% Remove Targets with a size less than minTargetExistTimeStamps
    %--------------------------------------------------------------------------
    disp(sepLine);
    disp('STEP 4, FILTERING OUT TARGETS WITH SHORT EXISTENCE PERIOD:');
    disp(sepLine);
    IDs=fieldnames(data.pp.holeTrace.targets);
    n2rm=0;
    for ii=1:length(IDs)
        l=size(data.pp.holeTrace.targets.(IDs{ii}),1);
        if( l<minTargetExistTimeStamps)
            n2rm=n2rm+1;
            data.pp.holeTrace.targets=rmfield(data.pp.holeTrace.targets,IDs{ii});
            data.pp.holeTrace.numberOfTargets=data.pp.holeTrace.numberOfTargets-1;
            iidx=find(ismember(data.pp.holeTrace.targetsExistenceRange(:,1),IDs{ii}));
            if length(iidx)>1
                disp('stzp')
            end
            data.pp.holeTrace.targetsExistenceRange(iidx,:)=[];
            disp(['Target ' ,IDs{ii} ,' was deleted besause its existence period (== '...
                , num2str(l),') is less than our predefined Threshold minTargetExistTimeStamps (== '...
                , num2str(minTargetExistTimeStamps),').']);
        end
    end
    if (n2rm==0)
        disp ('  ==> After the Size-Filtering Step, NO Targets have been deleted.');
    else
        
        disp (['  ==> After the Size-Filtering Step, ' num2str(n2rm)...
            ' Targets have been deleted.']);
    end
    %--------------------------------------------------------------------------
    %% Remove Targets with only NAN values for X and Y position
    %--------------------------------------------------------------------------
    disp(sepLine);
    disp('STEP 5, FILTERING OUT EXISTING TARGETS WITH ONLY NANs VALUES FOR X AND Y POS:');
    disp(sepLine);
    IDs=fieldnames(data.pp.holeTrace.targets);
    n2rm=0;
    for ii=1:length(IDs)
        idData=data.pp.holeTrace.targets.(IDs{ii});
        if( min(min(isnan(idData(:,2:3))))==1)
            n2rm=n2rm+1;
            data.pp.holeTrace.targets=rmfield(data.pp.holeTrace.targets,IDs{ii});
            data.pp.holeTrace.numberOfTargets=data.pp.holeTrace.numberOfTargets-1;
            iidx=find(ismember(data.pp.holeTrace.targetsExistenceRange(:,1),IDs{ii}));
            %iidx=find(contains(data.pp.holeTrace.targetsExistenceRange(:,1),IDs{ii}));
            data.pp.holeTrace.targetsExistenceRange(iidx,:)=[];
            disp(['Target ' ,IDs{ii} ,' was deleted besause its X and Y positions have only NANs values']);
        end
    end
    if (n2rm==0)
        disp ('  ==> After the NANs-Filtering Step, NO Targets have been deleted.');
    else
        disp (['  ==> After the NANs-Filtering Step, ' num2str(n2rm)...
            ' Targets have been deleted.']);
    end
    %--------------------------------------------------------------------------
    disp(sepLine);
    disp(['Number of Targets after all processing steps is: ' num2str(data.pp.holeTrace.numberOfTargets)]);
    disp(sepLine);
end
%--------------------------------------------------------------------------
if data.pp.holeTrace.numberOfTargets==0
    disp('After all processing steps No relevant Targets are existing. Scene is IRRELEVANT!!')
else
    pptargetsStr=[];
    ppcolors=zeros(3,data.pp.holeTrace.numberOfTargets);
    pptargetsID=data.pp.holeTrace.targetsExistenceRange(:,1);
    minColorsDiff=0.2;
    if (data.pp.holeTrace.numberOfTargets<=80)
        for obj=1:data.pp.holeTrace.numberOfTargets
            pptargetsStr{obj}=['Target' pptargetsID{obj}];
            if (obj==1)
                ppcolors(:,obj)=rand(3,1);
            else
                c=rand(3,1);
                while min(sqrt(sum((c*ones(1,obj-1)-ppcolors(:,1:obj-1)).^2)))< minColorsDiff
                    c=rand(3,1);
                end
                ppcolors(:,obj)=c;
            end
        end
    else
        for obj=1:data.pp.holeTrace.numberOfTargets
            pptargetsStr{obj}=['Target' pptargetsID{obj}];
            c=rand(3,1);
            ppcolors(:,obj)=c;
        end
    end
    
    %--------------------------------------------------------------------------
    %% calculate the curvature radius for all pp targets
    %--------------------------------------------------------------------------
    IDs=fieldnames(data.pp.holeTrace.targets);
    for ii=1:length(IDs)
        idData=data.pp.holeTrace.targets.(IDs{ii});
        Vel=sqrt(idData(:,4).^2+idData(:,5).^2);
        data.pp.holeTrace.targets.(IDs{ii})(:,10)=Vel ./ idData(:,9);
    end
    %--------------------------------------------------------------------------
    %% Save processed Data in excel sheets
    %--------------------------------------------------------------------------
    if (saveProcessedData)
        warning( 'off', 'MATLAB:xlswrite:AddSheet' ) ;
        excelName=['\' traceName '_processedData_GC.xlsx'];
        if exist([savePath excelName],'file')==2
            delete([savePath excelName]);
        end
        colHeader={'Time', 'X_pos', 'Y_pos', 'X_vel', 'Y_vel', 'X_acc' , 'Y_acc', 'Yaw', 'YawRate', 'R'};
        data2save=num2cell(data.egoData(:,1:9));
        data2save(isnan(data.egoData(:,1:9)))={'NaN'};
        data2save(isinf(data.egoData(:,1:9)) & (data.egoData(:,1:9)>0))={'Inf'};
        data2save(isinf(data.egoData(:,1:9)) & (data.egoData(:,1:9)<0))={'-Inf'};
        xlswrite([savePath excelName],data2save,1,'A2');
        xlswrite([savePath excelName],colHeader(1:9),1,'A1');%file (enter full path!)
        e = actxserver('Excel.Application'); % # open Activex server
        ewb = e.Workbooks.Open([savePath excelName]); % # open
        
        ewb.Worksheets.Item(1).Name = 'EgoData'; % # rename 1st sheet
        ewb.Save % # save to the same file
        ewb.Close(false)
        e.Quit
        for obj=1:data.pp.holeTrace.numberOfTargets
            data2save=num2cell(data.pp.holeTrace.targets.(pptargetsID{obj}));
            data2save(isnan(data.pp.holeTrace.targets.(pptargetsID{obj})))={'NaN'};
            data2save(isinf(data.pp.holeTrace.targets.(pptargetsID{obj})) & (data.pp.holeTrace.targets.(pptargetsID{obj})>0))= {'Inf'};
            data2save(isinf(data.pp.holeTrace.targets.(pptargetsID{obj})) & (data.pp.holeTrace.targets.(pptargetsID{obj})<0))= {'-Inf'};
            xlswrite([savePath excelName],data2save,pptargetsStr{obj},'A2');
            xlswrite([savePath excelName],colHeader,pptargetsStr{obj},'A1');
        end
    end
    %--------------------------------------------------------------------------
    %% Plotting Data
    %--------------------------------------------------------------------------
    data.orig.targetsStr=targetsStr;
    data.orig.targetsColors=colors;
    data.pp.holeTrace.pptragetsStr=pptargetsStr;
    data.pp.holeTrace.pptargetsColors=ppcolors;
    if (plotData)
        txt=sprintf('Target-ID    tentry     texit\n');
        txt=[txt sprintf('-------------------------------\n')];
        startPlotTimestamp=firstTargetEntry;
        endPlotTimeStamp=lastTargetExit;
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
        f=figure;
        coef=0.1;
        deltaX=coef/2*(maxXpos-minXpos);
        deltaY=coef/2*(maxYpos-minYpos);
        for i =startPlotTimestamp:endPlotTimeStamp
            plotVehicle([egoPosx(i),egoPosy(i)],egoYaw(i));
            hold on;
            h1=plot(egoPosx(1:i),egoPosy(1:i),'g');
            axis([minXpos-deltaX maxXpos+deltaX minYpos-deltaY (maxYpos+deltaY)]);
            if (plotData==1)
                for obj = 1:numberOfTargets
                    tentry=data.orig.targetsExistenceRange{obj,2}(1);
                    texit=data.orig.targetsExistenceRange{obj,2}(2);
                    if (i>=tentry && i<texit)
                        plotVehicle([targetData(i,colIdx_xpos01+idIndices(obj)),targetData(i,colIdx_ypos01+idIndices(obj))],targetData(i,colIdx_yaw01+idIndices(obj)),colors(:,obj)');
                        hold on;
                        plot(targetData(tentry:i,colIdx_xpos01+idIndices(obj)),targetData(tentry:i,colIdx_ypos01+idIndices(obj)),'Color',colors(:,obj),'LineWidth',2);
                    elseif (i>=texit)
                        plotVehicle([targetData(texit,colIdx_xpos01+idIndices(obj)),targetData(texit,colIdx_ypos01+idIndices(obj))],targetData(texit,colIdx_yaw01+idIndices(obj)),colors(:,obj)');
                        hold on;
                        h2(obj)=plot(targetData(tentry:texit,colIdx_xpos01+idIndices(obj)),targetData(tentry:texit,colIdx_ypos01+idIndices(obj)),'Color',colors(:,obj),'LineWidth',2);
                    end
                end
            else
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
                        h2(obj)=plot(data.pp.holeTrace.targets.(pptargetsID{obj})(:,2),data.pp.holeTrace.targets.(pptargetsID{obj})(:,3),'Color',ppcolors(:,obj),'LineWidth',2);
                    end
                end
            end
            hold off;
            pause(0.025);
            if i ~= endPlotTimeStamp
                clf;
            end
            xlabel('East');
            ylabel('North');
        end
        MyBox = uicontrol('style','text','Units','normalized');
        set(MyBox,'Position',[0.1,0.1,0.1,0.1]);
        fh=get(gca,'Position');
        if(plotData==1)
            legend([h1 h2],['EGO',targetsStr]);
            for obj=1:data.orig.numberOfTargets
                str1= sprintf('%.2f',timestamps(data.orig.targetsExistenceRange{obj,2}(1)));
                str2= sprintf('%.2f',timestamps(data.orig.targetsExistenceRange{obj,2}(2) ));
                txt=[txt sprintf(['   '  data.orig.targetsExistenceRange{obj,1} '       '    str1 '       ' str2 '\n' ])];
            end
            set(MyBox,'String',txt);
            boxExtent=get(MyBox,'Extent');
            set(MyBox,'Position',[fh(1)+fh(3)+0.005,fh(2)+fh(4)-boxExtent(4),boxExtent(3),boxExtent(4)]);
            title('Trajectories Visualization of Original-Data');
        else
            legend([h1 h2],['EGO',pptargetsStr]);
            for obj=1:data.pp.holeTrace.numberOfTargets
                str1= sprintf('%.2f',timestamps(data.pp.holeTrace.targetsExistenceRange{obj,2}(1)));
                str2= sprintf('%.2f',timestamps(data.pp.holeTrace.targetsExistenceRange{obj,2}(2) ));
                txt=[txt sprintf(['   '  data.pp.holeTrace.targetsExistenceRange{obj,1} '       '    str1 '       ' str2 '\n' ])];
            end
            set(MyBox,'String',txt);
            boxExtent=get(MyBox,'Extent');
            set(MyBox,'Position',[fh(1)+fh(3)+0.005,fh(2)+fh(4)-boxExtent(4),boxExtent(3),boxExtent(4)]);
            title('Trajectories Visualization of Processed-Data');
        end
    end
end
end



