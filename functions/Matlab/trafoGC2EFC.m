 %=============================================================================
%% function to Transform from Global coordinates to EGO fixed coordinates(EFC)
%% Run this function for getting EFC
%% Automotive Safety Technologies
%% Date:25.01.2019
%% Author: Bhagyaraj Dharmana
%% Input: 
%        data = dats struct including statis portions 
%% Output arguments:
%        data = data struct including the EFC  coordinate systems.
%=================================================================================

function data = trafoGC2EFC(data)
for i = 1:data.pp.staticTraces.nbr_staticPortions
    data.pp.staticTraces.(strcat('SP_',num2str(i))).EFC ={};
    timeExistence = data.pp.staticTraces.(strcat('SP_',num2str(i))).existenceRange;
    egoData = data.egoData(timeExistence(1):timeExistence(2),1:9);
    
    x_0 = egoData(1,2);                                                          % Initial X position
    y_0 = egoData(1,3);                                                          % Initial Y Position
    theta_0 =egoData(1,8);                                                       % Orientation Angle
    target2global_rot=[cos(theta_0) -sin(theta_0);sin(theta_0) cos(theta_0)];    %%Rotation matrix
    target2global =  [[target2global_rot ; 0 , 0] ,[x_0;y_0;1] ];                %% Transformation matrix
   
    
    %% Ego Traformation
    %---------------------------------------------------------------------
    time =egoData(:,1);
    ego_EFC_pos =target2global\[egoData(:,2)';egoData(:,3)';ones(1,size(egoData,1))];
    ego_EFC_vel =target2global_rot\[egoData(:,4)';egoData(:,5)'];
    ego_EFC_acc =target2global_rot\[egoData(:,6)';egoData(:,7)'];
    ego_EFC_yaw = egoData(:,8)-theta_0;
    ego_EFC_yawRate = egoData(:,9);
    
    data.pp.staticTraces.(strcat('SP_',num2str(i))).EFC.ego = [time,ego_EFC_pos(1,:)',...
        ego_EFC_pos(2,:)',ego_EFC_vel(1,:)',ego_EFC_vel(2,:)', ego_EFC_acc(1,:)',ego_EFC_acc(2,:)',ego_EFC_yaw,ego_EFC_yawRate];
    
    
    %% Targets traformation
    %----------------------------------------------------------------------
  
    for j = 1:length(data.pp.staticTraces.(strcat('SP_',num2str(i))).relevantTargetsID)
        ID = data.pp.staticTraces.(strcat('SP_',num2str(i))).relevantTargetsID(j);
        IDdata = data.pp.holeTrace.targets.(ID{1});
        time=IDdata(:,1);
        target_EFC_pos = target2global\[IDdata(:,2)';IDdata(:,3)';ones(1,size(IDdata,1))];
        target_EFC_vel = target2global_rot\[IDdata(:,4)';IDdata(:,5)'];
        target_EFC_acc=  target2global_rot\[IDdata(:,6)';IDdata(:,7)'];
        target_EFC_yaw =  IDdata(:,8)-theta_0;
        target_EFC_yawRate = IDdata(:,9);
        target_EFC_radius= (sqrt(target_EFC_vel(1,:)'.^2+target_EFC_vel(2,:)'.^2))./target_EFC_yawRate;
        
        data.pp.staticTraces.(strcat('SP_',num2str(i))).EFC.(ID{1}) =[time,target_EFC_pos(1,:)',...
            target_EFC_pos(2,:)',target_EFC_vel(1,:)',target_EFC_vel(2,:)', target_EFC_acc(1,:)',target_EFC_acc(2,:)',target_EFC_yaw,target_EFC_yawRate,target_EFC_radius];
    end
end


end