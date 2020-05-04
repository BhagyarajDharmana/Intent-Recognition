%=================================================================================================================================
%% Script for reading the labeled data and start training the RNN Model in python%%
%% Author: Bilel Said
%% Date  : 11.04.2019
%=================================================================================================================================
%---------------------------------------------------------------------------------------------------------------------------------
clear ;
close all;
clc;
%---------------------------------------------------------------------------------------------------------------------------------
%% Define settings forr reading relevant labeled Data
%---------------------------------------------------------------------------------------------------------------------------------
labeledDataPathIN = 'D:\PUBLIC\Internship\intentionrecognitionKAS\labeledData';
useEFC4Training = true;
useTj4Training = true;
augmentTurningTargets = false;
%---------------------------------------------------------------------------------------------------------------------------------
%% Define relevant training hyperparameters
%---------------------------------------------------------------------------------------------------------------------------------
learningRate=0.0081;                                                       % best learning rate was 0.009
epochs=100;
batch_size=8;
balanceData=true;
testRatio=0.1;
dropCoeff=0;
numberOfUnits=256;
%---------------------------------------------------------------------------------------------------------------------------------
if (useTj4Training)
    str2_FolderName = '_tj';
    maxInSeqLength = 300;
    tmp=1;
else
    str2_FolderName = '_all';
    maxInSeqLength = 350;
    tmp=0;
end
if (useEFC4Training)
    labeledDataPathIN=[labeledDataPathIN '\EFC'];
    str1_FolderName = '_EFC';
else
    labeledDataPathIN=[labeledDataPathIN '\TFC'];
    str1_FolderName = '_TFC';
end
if (balanceData)
    tmp1=1;
else
    tmp1=0;
end
%---------------------------------------------------------------------------------------------------------------------------------
%% Create new model subfolder under trainedModels
%---------------------------------------------------------------------------------------------------------------------------------
timeStamp=datestr(now,'yymmdd_HHMMSS');
modelFolderName = [timeStamp str1_FolderName str2_FolderName];
trainedModelPath=[pwd '\trainedModels\' modelFolderName];
mkdir(trainedModelPath);
pyFunctions=[pwd '\functions\python'];
labeledDataPathOUT=[trainedModelPath, '\labeledData.txt'];
%---------------------------------------------------------------------------------------------------------------------------------
%% Augment turning targets if necessary
%---------------------------------------------------------------------------------------------------------------------------------
if(augmentTurningTargets)
   disp('Augemnting the turning targets is not relevant for the moment as it shows no added value in the accuracy');
end
%---------------------------------------------------------------------------------------------------------------------------------
%% Gather all labeled Data and start training the model in python
%---------------------------------------------------------------------------------------------------------------------------------
command = ['python ',pyFunctions, '\trainModel_main.py',' --labeledDataPathIN ', labeledDataPathIN,...
    ' --trainedModelPath ', trainedModelPath,' --useTj4Training ', num2str(tmp),...
    ' --learningRate ',num2str(learningRate),' --epochs ',num2str(epochs),' --batch_size ',num2str(batch_size),...
    ' --balanceData ',num2str(tmp1), ' --testRatio ',num2str(testRatio), ' --dropCoeff ', num2str(dropCoeff),...
    ' --numberOfUnits ',num2str(numberOfUnits)];
system(command);
%---------------------------------------------------------------------------------------------------------------------------------
