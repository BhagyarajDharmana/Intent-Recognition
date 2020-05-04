%% function to find static scenes of ego and relavant targets in that existence range
%% Run this function for getting the static scenes
%% Automotive Safety Technologies
%% Date:25.01.2019
%% Author: Bhagyaraj Dharmana
%% Input Arguments are  
%                     data          = data struct after all dynamic_preprocessing
%                     min_ego_speed = speed assigned as a parameter to check for velocities which are less than this speed for extracting static portions 
%% Output Arguments
%                     data          = data struct with  Individual static portions and relavant targets in EFC and TFC
%% Structure of the data at the end of this function
% data-->pptargets-->staticTraces-->1.nbr_staticPortions
%                                   2.Relavant Targets
%                                   3.EFC-->1.SP_(i)-->all relavant targets
%                                                      and ego
%                                            
%                                   4.TFC--> all relavant targets
%================================================================================================================================

function data= extractStaticPortions(data,min_ego_speed)

time = data.time;
ego_velx= data.egoData(:,4);
ego_vely= data.egoData(:,5);
targetsIDs = fieldnames(data.pp.holeTrace.targets);
lowVelocityIdx = [];
%--------------------------------------------------------------------------
%checking for velocity less than min_ego_velocity and saving the indicex oftime stamps
for i = 1:length(ego_velx)
    if sqrt(ego_velx(i)^2+ego_vely(i)^2) <= min_ego_speed
        lowVelocityIdx = [lowVelocityIdx;i];
    end
end
%--------------------------------------------------------------------------
% finding the no.of static portions, exit and entry time of the each static portion
if isempty(lowVelocityIdx)
    data.pp.staticTraces.nbr_staticPortions=0;
else
    entryTimeStamps=lowVelocityIdx(1);
    exitTimeStamps= [];
    for idx = 2:length(lowVelocityIdx)
        if lowVelocityIdx(idx)-lowVelocityIdx(idx-1)>1
            entryTimeStamps= [entryTimeStamps lowVelocityIdx(idx)];
            exitTimeStamps= [exitTimeStamps lowVelocityIdx(idx-1) ];
        end
    end
    exitTimeStamps= [exitTimeStamps lowVelocityIdx(end)];
    no_of_static_scenes=length(entryTimeStamps);
%--------------------------------------------------------------------------
% saving the existence range to the data struct   
    data.pp.staticTraces.nbr_staticPortions=no_of_static_scenes;
    for scene = 1:no_of_static_scenes
        data.pp.staticTraces.(strcat('SP_',num2str(scene))).existenceRange= [entryTimeStamps(scene) exitTimeStamps(scene)];
    end
%--------------------------------------------------------------------------
% finding the realavant targets in the individual trace
    for ii=1:no_of_static_scenes
        data.pp.staticTraces.(strcat('SP_',num2str(ii))).relevantTargetsID={};
    end
    %--------------------------------------------------------------------------
    for id = 1:data.pp.holeTrace.numberOfTargets
        targetData = getfield(data.pp.holeTrace.targets,targetsIDs{id});
        t_start =  targetData(1,1);
        t_end = targetData(end,1);
        
        for ii=1:no_of_static_scenes
            if (t_start<time(exitTimeStamps(ii))) && (t_end>time(entryTimeStamps(ii)))
                data.pp.staticTraces.(strcat('SP_',num2str(ii))).relevantTargetsID{end+1}=targetsIDs{id};
                break; 
            end
        end
    end
end
end