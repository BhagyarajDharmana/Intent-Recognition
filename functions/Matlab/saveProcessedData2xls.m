%=================================================================================================================================
%% Function to save processed data to Xlsx file
%% Run this file to save all data in Global coordinates,Ego fixed coordinates and target fixed coordinates to excel sheets.
%% Author: Bilel said(AST-E42)
%% Date 25.01.2019
%% Input Arguments are  
%                     savePath   = Path for saving the xls sheets
%                     tracename  = Name of the specific trace folder
%                     data       = data struct after all preprocessing and transformation
%% Output Arguments
%  Save global coordinates into xlsx in the path  (D:\PUBLIC\Internship\Trace_data\traceName\processedData)
%  Save  ego fixed coordinates and target fixed coordinates of individual static trace in the same path (D:\PUBLIC\Internship\Trace_data\traceName\processedData
%=================================================================================================================================
function saveProcessedData2xls(savePath,traceName,data)
%--------------------------------------------------------------------------
%% Save Global coordinates into xlsx file
%--------------------------------------------------------------------------
savePath=[savePath, '\processedData'];
if ~isfolder(savePath)
    mkdir(savePath)
end
pptargetsID=data.pp.holeTrace.targetsExistenceRange(:,1);
warning( 'off', 'MATLAB:xlswrite:AddSheet' ) ;
gc_excelName=['\' traceName '_processedData_GC.xlsx'];
if exist([savePath gc_excelName],'file')==2                                 % Delete the excel file with the same name
    delete([savePath gc_excelName]);
end

% saving Ego data

colHeader={'Time', 'X_pos', 'Y_pos', 'X_vel', 'Y_vel', 'X_acc' , 'Y_acc', 'Yaw', 'YawRate', 'R'};
data2save=num2cell(data.egoData(:,1:9));
data2save(isnan(data.egoData(:,1:9)))={'NaN'};
data2save(isinf(data.egoData(:,1:9)) & (data.egoData(:,1:9)>0))={'Inf'};
data2save(isinf(data.egoData(:,1:9)) & (data.egoData(:,1:9)<0))={'-Inf'};
xlswrite([savePath gc_excelName],data2save,1,'A2');
xlswrite([savePath gc_excelName],colHeader(1:9),1,'A1');                    % file (enter full path!)
e = actxserver('Excel.Application');                                        % open Activex server
ewb = e.Workbooks.Open([savePath gc_excelName]);                            % open 
ewb.Worksheets.Item(1).Name = 'EgoData';                                    % rename 1st sheet
ewb.Save                                                                    % save to the same file
ewb.Close(false)
e.Quit

% saving Targets data

for obj=1:data.pp.holeTrace.numberOfTargets
    data2save=num2cell(data.pp.holeTrace.targets.(pptargetsID{obj}));
    data2save(isnan(data.pp.holeTrace.targets.(pptargetsID{obj})))={'NaN'};
    data2save(isinf(data.pp.holeTrace.targets.(pptargetsID{obj})) & (data.pp.holeTrace.targets.(pptargetsID{obj})>0))= {'Inf'};
    data2save(isinf(data.pp.holeTrace.targets.(pptargetsID{obj})) & (data.pp.holeTrace.targets.(pptargetsID{obj})<0))= {'-Inf'};
    xlswrite([savePath gc_excelName],data2save,strcat('Target_',pptargetsID{obj}),'A2');
    xlswrite([savePath gc_excelName],colHeader,strcat('Target_',pptargetsID{obj}),'A1');
end

%--------------------------------------------------------------------------
%% Save static portions EFC Data
%%
if (data.pp.staticTraces.nbr_staticPortions>=1)                             
    
    for i=1:data.pp.staticTraces.nbr_staticPortions
        efc_excelName=['\' traceName '_processedData_SP_',num2str(i),'_EFC.xlsx'];
        if exist([savePath efc_excelName],'file')==2
            delete([savePath efc_excelName]);
        end
%Saving Ego data of a particular scene i
        efc_ego=data.pp.staticTraces.(strcat('SP_',num2str(i))).EFC.ego;
        data2save=num2cell(efc_ego);
        data2save(isnan(efc_ego))={'NaN'};
        data2save(isinf(efc_ego) & (efc_ego>0))={'Inf'};
        data2save(isinf(efc_ego) & (efc_ego<0))={'-Inf'};
        xlswrite([savePath efc_excelName],data2save,1,'A2');
        xlswrite([savePath efc_excelName],colHeader(1:9),1,'A1');          %file (enter full path!)
        e = actxserver('Excel.Application');                               % # open Activex server
        ewb = e.Workbooks.Open([savePath efc_excelName]);                  % # open
        ewb.Worksheets.Item(1).Name = 'EgoData';                           % # rename 1st sheet
        ewb.Save                                                           % # save to the same file
        ewb.Close(false)
        e.Quit
% Saving all the relavant targets of scene i        
        for obj=1:length(data.pp.staticTraces.(strcat('SP_',num2str(i))).relevantTargetsID)
            Id = data.pp.staticTraces.(strcat('SP_',num2str(i))).relevantTargetsID{obj};
            data2save=num2cell(data.pp.staticTraces.(strcat('SP_',num2str(i))).EFC.(Id));
            data2save(isnan(data.pp.staticTraces.(strcat('SP_',num2str(i))).EFC.(Id)))={'NaN'};
            data2save(isinf(data.pp.staticTraces.(strcat('SP_',num2str(i))).EFC.(Id)) & (data.pp.staticTraces.(strcat('SP_',num2str(i))).EFC.(Id)>0))= {'Inf'};
            data2save(isinf(data.pp.staticTraces.(strcat('SP_',num2str(i))).EFC.(Id)) & (data.pp.staticTraces.(strcat('SP_',num2str(i))).EFC.(Id)<0))= {'-Inf'};
            xlswrite([savePath efc_excelName],data2save,(strcat('Target_',Id)),'A2');
            xlswrite([savePath efc_excelName],colHeader,(strcat('Target_',Id)),'A1');
        end
    end
%--------------------------------------------------------------------------
%% save static portions TFC Data
%%
    for i=1:data.pp.staticTraces.nbr_staticPortions
        tfc_excelName=['\' traceName '_processedData_SP_',num2str(i),'_TFC.xlsx'];
        if exist([savePath tfc_excelName],'file')==2
            delete([savePath tfc_excelName]);
        end
      % Saving all relavant coordinates in TFC  
        obj=1;
        Id = data.pp.staticTraces.(strcat('SP_',num2str(i))).relevantTargetsID{obj};
        data2save=num2cell(data.pp.staticTraces.(strcat('SP_',num2str(i))).TFC.(Id));
        data2save(isnan(data.pp.staticTraces.(strcat('SP_',num2str(i))).TFC.(Id)))={'NaN'};
        data2save(isinf(data.pp.staticTraces.(strcat('SP_',num2str(i))).TFC.(Id)) & (data.pp.staticTraces.(strcat('SP_',num2str(i))).TFC.(Id)>0))= {'Inf'};
        data2save(isinf(data.pp.staticTraces.(strcat('SP_',num2str(i))).TFC.(Id)) & (data.pp.staticTraces.(strcat('SP_',num2str(i))).TFC.(Id)<0))= {'-Inf'};
        xlswrite([savePath tfc_excelName],data2save,1,'A2');
        xlswrite([savePath tfc_excelName],colHeader,1,'A1');
        e = actxserver('Excel.Application');
        ewb = e.Workbooks.Open([savePath tfc_excelName]);
        ewb.Worksheets.Item(1).Name = strcat('Target_',Id);
        ewb.Save
        ewb.Close(false)
        e.Quit
        for obj=2:length(data.pp.staticTraces.(strcat('SP_',num2str(i))).relevantTargetsID)
            Id = data.pp.staticTraces.(strcat('SP_',num2str(i))).relevantTargetsID{obj};
            data2save=num2cell(data.pp.staticTraces.(strcat('SP_',num2str(i))).TFC.(Id));
            data2save(isnan(data.pp.staticTraces.(strcat('SP_',num2str(i))).TFC.(Id)))={'NaN'};
            data2save(isinf(data.pp.staticTraces.(strcat('SP_',num2str(i))).TFC.(Id)) & (data.pp.staticTraces.(strcat('SP_',num2str(i))).TFC.(Id)>0))= {'Inf'};
            data2save(isinf(data.pp.staticTraces.(strcat('SP_',num2str(i))).TFC.(Id)) & (data.pp.staticTraces.(strcat('SP_',num2str(i))).TFC.(Id)<0))= {'-Inf'};
            xlswrite([savePath tfc_excelName],data2save,(strcat('Target_',Id)),'A2');
            xlswrite([savePath tfc_excelName],colHeader,(strcat('Target_',Id)),'A1');
        end
    end
end
end