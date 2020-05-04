function labeledDataReadMe(path2LabeledData,par)

StraightTargets = 0;
TurningTargets  = 0;
IrrelevantTargets= 0;
cd([path2LabeledData,'\EFC'])
list = dir('*.txt');
NbrofScenes = size(list,1);

for i= 1:size(list,1)
    filename=list(i).name;
    reader=fopen(filename);
    % Get file size.
    fseek(reader, 0, 'eof');
    fileSize = ftell(reader);
    frewind(reader);
    % Read the whole file.
    data = fread(reader, fileSize, 'uint8');
    % Count number of line-feeds and increase by one.
    numLines = sum(data == 10) + 1;
    fclose(reader);
    reader=fopen(filename);
    for j =1:numLines
        tline = fgetl(reader);
        if strcmp(tline,'Label: 1')
            TurningTargets=TurningTargets+1;
        elseif strcmp(tline,'Label: 0')
            StraightTargets=StraightTargets+1;
        elseif strcmp(tline,'Label: -1')
            IrrelevantTargets=IrrelevantTargets+1;
        else
            continue;
        end
    end
    
    fclose(reader);
end
relevantTargets=TurningTargets+StraightTargets;
allTargets=relevantTargets+IrrelevantTargets;
if exist([path2LabeledData,'\readME.txt'],'file')==2
    delete([path2LabeledData,'\readMe.txt']);
end
% save relevant labeling parameters:
dlmwrite([path2LabeledData,'\readMe.txt'],'-------------------------------------------------------------------------------------------------------------------',...
    'delimiter','','newline','pc','-append');
dlmwrite([path2LabeledData,'\readMe.txt'],'Relevant Parameters used for Labeling:','delimiter','','newline','pc','-append');
dlmwrite([path2LabeledData,'\readMe.txt'],'-------------------------------------------------------------------------------------------------------------------',...
    'delimiter','','newline','pc','-append');
dlmwrite([path2LabeledData,'\readMe.txt'],['minTargetExistTimeStamps: ', num2str(par.minTargetExistTimeStamps), ' [-]'],'delimiter','','newline','pc','-append');
dlmwrite([path2LabeledData,'\readMe.txt'],['min ego speed for static portions estimation: ', num2str(par.min_ego_speed),' [m/s]'],'delimiter','','newline','pc','-append');
dlmwrite([path2LabeledData,'\readMe.txt'],['distance to virtual holding line in EFC coordinates: ', num2str(par.distance2holdingLine),' [m]'],'delimiter','','newline','pc','-append');

% save relevant statistics
dlmwrite([path2LabeledData,'\readMe.txt'],'-------------------------------------------------------------------------------------------------------------------',...
    'delimiter','','newline','pc','-append');
dlmwrite([path2LabeledData,'\readMe.txt'],'Original Labeled data statistics:','delimiter','','newline','pc','-append');
dlmwrite([path2LabeledData,'\readMe.txt'],'-------------------------------------------------------------------------------------------------------------------',...
    'delimiter','','newline','pc','-append');
dlmwrite([path2LabeledData,'\readMe.txt'],['Total number of  scenes is: ' num2str(NbrofScenes) ],'delimiter','','newline','pc','-append');
dlmwrite([path2LabeledData,'\readMe.txt'],['Number of irrelevant Targets: ', num2str(IrrelevantTargets),' ==> ',num2str(IrrelevantTargets/allTargets*100),' %.'],'delimiter','','newline','pc','-append');
dlmwrite([path2LabeledData,'\readMe.txt'],['Number of relevant Targets: ' num2str(relevantTargets),' ==> ',num2str(relevantTargets/allTargets*100),' %.'],'delimiter','','newline','pc','-append');
dlmwrite([path2LabeledData,'\readMe.txt'],['Number of  turning Targets: ' num2str(TurningTargets),' ==> ',num2str(TurningTargets/allTargets*100),' %.'],'delimiter','','newline','pc','-append');
dlmwrite([path2LabeledData,'\readMe.txt'],['Number of straight Targets: ' num2str(StraightTargets),' ==> ',num2str(StraightTargets/allTargets*100),' %.'],'delimiter','','newline','pc','-append');
dlmwrite([path2LabeledData,'\readMe.txt'],'-------------------------------------------------------------------------------------------------------------------',...
    'delimiter','','newline','pc','-append');
end