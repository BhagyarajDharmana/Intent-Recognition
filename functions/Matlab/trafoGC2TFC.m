%=================================================================================
%% function to Transform from Global coordinates to TARGET fixed coordinates(TFC)
%% Run this function for getting EFC
%% Automotive Safety Technologies
%% Date:25.01.2019
%% Author: Bhagyaraj Dharmana
%% Input: 
%        data = dats struct including statis portions 
%% Output arguments:
%        data = data struct including the EFC  coordinate systems.
%=================================================================================

 function data = trafoGC2TFC(data)

for i = 1:data.pp.staticTraces.nbr_staticPortions
    data.pp.staticTraces.(strcat('SP_',num2str(i))).TFC ={};
    for j = 1:length(data.pp.staticTraces.(strcat('SP_',num2str(i))).relevantTargetsID)
        ID = data.pp.staticTraces.(strcat('SP_',num2str(i))).relevantTargetsID(j);
        Iddata = data.pp.holeTrace.targets.(ID{1});
        x_0= Iddata(1,2);                                                   %Initial Xpos of Target
        y_0= Iddata(1,3);                                                   %Initial Y pos of Target
        theta_0= Iddata(1,8);                                               %Oritation angle of Target
        time=Iddata(:,1);    
        X_GC=Iddata(:,2);                                                  %Posx vector of target in global coordinates
        Y_GC=Iddata(:,3);                                                  %Posy vector of target in global coordinates
        VX_GC=Iddata(:,4);                                                 %Velx vector of target in global coordinates
        VY_GC=Iddata(:,5);                                                 %Vely vector of target in global coordinates
        AX_GC=Iddata(:,6);                                                 %Accx vector of target in global coordinates
        AY_GC=Iddata(:,7);                                                 %Accy vector of target in global coordinates
        YAW_GC=Iddata(:,8);                                                %YAww of target in global coordinates
        YAWRATE_GC=Iddata(:,9);    
        
        target2global_rot=[cos(theta_0) -sin(theta_0);sin(theta_0) cos(theta_0)];   %% Rotation matrix
        target2global =  [[target2global_rot ; 0 , 0] ,[x_0;y_0;1] ];               %% Transformation matrix
        
        target_TFC_pos = target2global\[X_GC';Y_GC'; ones(1,length(Y_GC))];
        target_TFC_vel = target2global_rot\[VX_GC';VY_GC'];
        target_TFC_acc = target2global_rot\[AX_GC';AY_GC'];
        target_TFC_yaw = YAW_GC - theta_0;
        target_TFC_yawRate = YAWRATE_GC;
        target_TFC_radius= (sqrt(target_TFC_vel(1,:)'.^2+target_TFC_vel(2,:)'.^2))./target_TFC_yawRate;
        
        data.pp.staticTraces.(strcat('SP_',num2str(i))).TFC.(ID{1}) = [time,target_TFC_pos(1,:)',...
            target_TFC_pos(2,:)',target_TFC_vel(1,:)',target_TFC_vel(2,:)', target_TFC_acc(1,:)',target_TFC_acc(2,:)',target_TFC_yaw,target_TFC_yawRate,target_TFC_radius];        
    end
end
end

