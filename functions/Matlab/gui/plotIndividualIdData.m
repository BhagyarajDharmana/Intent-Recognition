function plotIndividualIdData(h,data,idStr, cordType)
if strcmp(cordType,'Global')
    relData=data.pp.holeTrace.targets;
else
    for i=1:data.pp.staticTraces.nbr_staticPortions
        if any(ismember(data.pp.staticTraces.(['SP_',num2str(i)]).relevantTargetsID,idStr))
            statIdx=i;
        end
    end
    if strcmp(cordType,'EFC')
        relData=data.pp.staticTraces.(['SP_',num2str(statIdx)]).EFC;
    else
        relData=data.pp.staticTraces.(['SP_',num2str(statIdx)]).TFC;
    end
end
plot(h.axesPos,relData.(idStr)(:,2),relData.(idStr)(:,3));
title(h.axesPos,[cordType,'-Position']);
xlabel(h.axesPos,'x [m]');
ylabel(h.axesPos,'y [m]');
grid(h.axesPos,'on')

plot(h.axesVelx,relData.(idStr)(:,1),relData.(idStr)(:,4));
title(h.axesVelx,[cordType,'-Velocity']);
ylabel(h.axesVelx,'Vx [m/s]');
grid(h.axesVelx,'on')

plot(h.axesVely,relData.(idStr)(:,1),relData.(idStr)(:,5),'r');
xlabel(h.axesVely,'t [s]');
ylabel(h.axesVely,'Vy [m/s]');
grid(h.axesVely,'on')

plot(h.axesAccx,relData.(idStr)(:,1),relData.(idStr)(:,6));
title(h.axesAccx,[cordType,'-Acceleration']);
ylabel(h.axesAccx,'Ax [m/s^2]');
grid(h.axesAccx,'on')

plot(h.axesAccy,relData.(idStr)(:,1),relData.(idStr)(:,7),'r');
xlabel(h.axesAccy,'t [s]');
ylabel(h.axesAccy,'Ay [m/s^2]');
grid(h.axesAccy,'on');

plot(h.axesYaw,relData.(idStr)(:,1),relData.(idStr)(:,8));
title(h.axesYaw,[cordType,'-Yaw']);
ylabel(h.axesYaw,'Yaw [rad]');
grid(h.axesYaw,'on')

plot(h.axesYawrate,relData.(idStr)(:,1),relData.(idStr)(:,9));
title(h.axesYawrate,[cordType,'-Yawrate']);
xlabel(h.axesYawrate,'t [s]');
ylabel(h.axesYawrate,'YawRate [rad/s]');
grid(h.axesYawrate,'on')

end