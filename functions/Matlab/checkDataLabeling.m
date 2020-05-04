function data=checkDataLabeling(data,target_EFC,target_TFC, Id, distance2holdingLine,savePath,traceName)
savePath_EFC=[savePath, '\EFC\'];
savePath_TFC=[savePath, '\TFC\'];
%--------------------------------------------------------------------------
nStamps=10;
minTargetTimeStamps = 2*nStamps;
idStr = num2str(Id);
%--------------------------------------------------------------------------
targetTime = target_EFC(:,1);
clean_targetY = rmmissing(target_EFC(:,3));
velX=target_EFC(:,4);
velY=target_EFC(:,5);
vel_x_cleanlist = rmmissing(velX);
vel_y_cleanlist = rmmissing(velY);
%--------------------------------------------------------------------------
if (length(targetTime)<=minTargetTimeStamps)||(min(length(vel_x_cleanlist),length(vel_y_cleanlist))<=nStamps)
    disp(['------------------------->' idStr ' can not be processed due to lack of data' '<------------------------']);
    isTargetRelevant = false;
    tj=inf;
    label=-1;
    comment='Target can not be processed due to lack of Data';
    dlmwrite([savePath_EFC,traceName,'.txt'],['TargetID: ',Id],'delimiter','','newline','pc','-append');
    dlmwrite([savePath_EFC,traceName,'.txt'],comment,'delimiter','','newline','pc','-append');
    dlmwrite([savePath_EFC,traceName,'.txt'],'******-------------------------------------------------------------------------------------------------------------------****** ',...
        'delimiter','','newline','pc','-append');
    dlmwrite([savePath_TFC,traceName,'.txt'],['TargetID: ',Id],'delimiter','','newline','pc','-append');
    dlmwrite([savePath_TFC,traceName,'.txt'],comment,'delimiter','','newline','pc','-append');
    dlmwrite([savePath_TFC,traceName,'.txt'],'******-------------------------------------------------------------------------------------------------------------------****** ',...
        'delimiter','','newline','pc','-append');
    % save label informations in data struct
    data.pp.targetsLabel.(Id).relevancy=isTargetRelevant;
    data.pp.targetsLabel.(Id).label=label;
    data.pp.targetsLabel.(Id).tj=tj;
    data.pp.targetsLabel.(Id).comment=comment;
    return;
end
disp(['------------------------->' idStr ' is getting processed now' '<------------------------']);
[isTargetRelevant,tj]=targetRelevancy(target_EFC(:,3),clean_targetY,distance2holdingLine,targetTime);
iscrossingX=intersectXEGO(clean_targetY);
%--------------------------------------------------------------------------
% Calculating velocity Ratio
%--------------------------------------------------------------------------
vel_ratio=[];
for k=1:length(velX)
    if ~(isnan(velX(k))|| isnan(velY(k)))
        currRatio=velX(k)^2/(velX(k)^2+velY(k)^2);
        vel_ratio =[vel_ratio;currRatio];
    end
end
if (length(vel_ratio)<=nStamps)
    disp(['------------------------->' idStr ' can not be processed due to lack of data' '<------------------------']);
    isTargetRelevant = false;
    tj=inf;
    label=-1;
    comment='Target can not be processed due to lack of Data';
    dlmwrite([savePath_EFC,traceName,'.txt'],['TargetID: ',Id],'delimiter','','newline','pc','-append');
    dlmwrite([savePath_EFC,traceName,'.txt'],comment,'delimiter','','newline','pc','-append');
    dlmwrite([savePath_EFC,traceName,'.txt'],'******-------------------------------------------------------------------------------------------------------------------****** ',...
        'delimiter','','newline','pc','-append');
    dlmwrite([savePath_TFC,traceName,'.txt'],['TargetID: ',Id],'delimiter','','newline','pc','-append');
    dlmwrite([savePath_TFC,traceName,'.txt'],comment,'delimiter','','newline','pc','-append');
    dlmwrite([savePath_TFC,traceName,'.txt'],'******-------------------------------------------------------------------------------------------------------------------****** ',...
        'delimiter','','newline','pc','-append');
    % save label informations in data struct
    data.pp.targetsLabel.(Id).relevancy=isTargetRelevant;
    data.pp.targetsLabel.(Id).label=label;
    data.pp.targetsLabel.(Id).tj=tj;
    data.pp.targetsLabel.(Id).comment=comment;
    return;
end
vel_ratio_mean = mean(vel_ratio);
vel_ratio_meanBottom = mean(vel_ratio(end-nStamps:end));
disp(['velocity ratio mean value: ' num2str(vel_ratio_mean)]);
disp(['mean value of 10 bot elements of vel. ratio:' num2str(vel_ratio_meanBottom)]);
disp(['abs diff vel_ratio_meanBottom-vel_ratio_mean: ',num2str(abs(vel_ratio_meanBottom-vel_ratio_mean))]);
%--------------------------------------------------------------------------
% Labeling ID
%--------------------------------------------------------------------------
if isTargetRelevant == true
    if iscrossingX==true
        label=0;
        comment = 'Target is relevant and going straight, since target is crossing Ego X-axis in EFC';
    elseif abs(vel_ratio_meanBottom-vel_ratio_mean)>=0.2
        comment = 'Target is relevant and Turning, since the velocity ratio is highly changing at the end';
        label=1;
    else
        label=0;
        comment = 'Target is relevant and going straight, since the velocity ratio is almost not changing';
    end
else
    label=-1;
    comment='Target is irrelevant as it is not crossing the estimated holding line';
end
disp(comment);
%--------------------------------------------------------------------------
% save Data dynamic data and label class in EFC coordinates system
%--------------------------------------------------------------------------
dlmwrite([savePath_EFC,traceName,'.txt'],['TargetID: ',Id],'delimiter','','newline','pc','-append');
dlmwrite([savePath_EFC,traceName,'.txt'],['Relevancy: ',num2str(isTargetRelevant)],'delimiter','','newline','pc','-append');
dlmwrite([savePath_EFC,traceName,'.txt'],['tj = ',num2str(tj)],'delimiter','','newline','pc','-append');
dlmwrite([savePath_EFC,traceName,'.txt'],['Label: ',num2str(label)],'delimiter','','newline','pc','-append');
dlmwrite([savePath_EFC,traceName,'.txt'],['Comment: ',comment],'delimiter','','newline','pc','-append');
%if (isTargetRelevant)
dlmwrite([savePath_EFC,traceName,'.txt'],'DATA:' ,'delimiter','','newline','pc','-append');
dlmwrite([savePath_EFC,traceName,'.txt'],target_EFC,'delimiter',',','newline','pc','-append');
%dlmwrite([savePath_EFC,traceName,'.txt'],' ','delimiter','\n','newline','pc','-append');
%end
dlmwrite([savePath_EFC,traceName,'.txt'],'******-------------------------------------------------------------------------------------------------------------------****** ',...
    'delimiter','','newline','pc','-append');
%--------------------------------------------------------------------------
% save Data dynamic data and label class in TFC coordinates system
%--------------------------------------------------------------------------
dlmwrite([savePath_TFC,traceName,'.txt'],['TargetID: ',Id],'delimiter','','newline','pc','-append');
dlmwrite([savePath_TFC,traceName,'.txt'],['Relevancy: ',num2str(isTargetRelevant)],'delimiter','','newline','pc','-append');
dlmwrite([savePath_TFC,traceName,'.txt'],['tj = ',num2str(tj)],'delimiter','','newline','pc','-append');
dlmwrite([savePath_TFC,traceName,'.txt'],['Label: ',num2str(label)],'delimiter','','newline','pc','-append');
dlmwrite([savePath_TFC,traceName,'.txt'],['Comment: ',comment],'delimiter','','newline','pc','-append');
%if (isTargetRelevant)
dlmwrite([savePath_TFC,traceName,'.txt'],'DATA:' ,'delimiter','','newline','pc','-append');
dlmwrite([savePath_TFC,traceName,'.txt'],target_TFC,'delimiter',',','newline','pc','-append');
%dlmwrite([savePath_TFC,traceName,'.txt'],' ','delimiter','\n','newline','pc','-append');
%end
dlmwrite([savePath_TFC,traceName,'.txt'],'******-------------------------------------------------------------------------------------------------------------------****** ',...
    'delimiter','','newline','pc','-append');

% save label informations in data struct
data.pp.targetsLabel.(Id).relevancy=isTargetRelevant;
data.pp.targetsLabel.(Id).label=label;
data.pp.targetsLabel.(Id).tj=tj;
data.pp.targetsLabel.(Id).comment=comment;
end
%--------------------------------------------------------------------------
% check if the Target Object is crossing EGO X-axis
%--------------------------------------------------------------------------
function iscrossingX = intersectXEGO(target_posY)
iscrossingX=(max(sign(target_posY))==1)&& (min(sign(target_posY))==-1);
end
%--------------------------------------------------------------------------
% Check Target relevancy by looking if Target is crossing the holding line
%--------------------------------------------------------------------------
function [isTargetRelevant,tj] = targetRelevancy(target_posY,noNanTarget_posY,distance2holdingLine,time)
idx = 1;
maximum_Holdingline_left = 1 * distance2holdingLine;
maximum_Holdingline_right = -1 * distance2holdingLine;
isTargetRelevant=false;
tj=inf;
for ii=1:length(target_posY)
    posY_ii = target_posY(ii);
    if ((noNanTarget_posY(1)>maximum_Holdingline_left && posY_ii<=maximum_Holdingline_left) || (noNanTarget_posY(1)<maximum_Holdingline_right && posY_ii>=maximum_Holdingline_right))
        isTargetRelevant=true;
        tj = time(idx);
        break;
    else
        idx=idx+1;
    end
end
end
