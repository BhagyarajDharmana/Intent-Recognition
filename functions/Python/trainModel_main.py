##############################################
DEFINE_OneDimModel = True
##############################################
import argparse
from readLabeledData import readLabeledData
if DEFINE_OneDimModel == True: 
    from trainLstmModelOneDim import trainLstmModel
else:
    from trainLstmModelTwoDim import trainLstmModel

def main():
    labeledDataPathIN=args.labeledDataPathIN
    trainedModelPath=args.trainedModelPath
    useTj4Training=args.useTj4Training
    learningRate=args.learningRate
    epochs=args.epochs
    batch_size=args.batch_size
    balanceData=args.balanceData
    testRatio=args.testRatio
    dropCoeff=args.dropCoeff
    numberOfUnits=args.numberOfUnits
    labeledDataPathOUT=trainedModelPath+'\\labeledData.txt'
    print('*****************************************************************************')
    print('Read all labeled data under: ' ,labeledDataPathIN)
    print('*****************************************************************************')
    readLabeledData(labeledDataPathIN,labeledDataPathOUT,useTj4Training)
    h = open(trainedModelPath+'\\readMe.txt',"a+")
    h.write('***************************************************************************'+'\n')
    h.write('RNN model Informations:'+'\n')
    h.write('Please consider following hints when deploying the model:'+'\n')
    h.write('***************************************************************************'+'\n')
    h1=open(labeledDataPathIN[:-4]+'\\readMe.txt',"r")
    for line in h1:
        h.write(line)    
    print('*****************************************************************************')
    print('Readinbg labeled data done. All relevant data is stored in one TXT file under: ',labeledDataPathOUT)
    print('*****************************************************************************')
    print('Start training the Model:')
    if DEFINE_OneDimModel == True:
        print('trainLstmModelOneDim is considered for the training.')
    else:
        print('trainLstmModelTwoDim is considered for the training.')
    print('*****************************************************************************')
    nStr, nTurn, maxLength, minLength, accTest=trainLstmModel(labeledDataPathOUT,trainedModelPath,learningRate,epochs,batch_size,balanceData,testRatio,dropCoeff,numberOfUnits)
    h.write('Relevant Labeled Targets (for Training) informations:'+'\n')
    h.write('---------------------------------------------------------------------------'+'\n')
    h.write('maxLength (Nbr. of timestamps) of relevant Data : '+str(maxLength)+ ' --> consider this value for padding the data before deploying the model'+'\n')
    h.write('minLength (Nbr. of timestamps) of relevant Data : '+str(minLength)+'\n')
    if 'EFC' in trainedModelPath:
        h.write('--> model is considering EFC coordinates Data'+'\n')
    else:
        h.write('--> model is considering TFC coordinates Data'+'\n')
    if useTj4Training !=0:
        h.write('--> model is considering tj'+'\n')
    else:
        h.write('--> model is NOT considering tj'+'\n')
    if DEFINE_OneDimModel == True:
        h.write('--> LstmModel with One Dimensional output is considered for the training.\n')
    else:
        h.write('--> LstmModel with Two Dimensional output is considered for the training.\n')
    h.write('---------------------------------------------------------------------------'+'\n')
    h.write('Number of relevant Targets for Training & Testing the RNN Model:'+'\n')
    h.write('---------------------------------------------------------------------------'+'\n')
    h.write('Number of straight targets in relevant Dataset (for training, validation and testing): '+ str(nStr)+'\n')
    h.write('Number of turning targets in relevant Dataset (for training, validation and testing): '+ str(nTurn)+'\n')
    if balanceData != 0:
        h.write('--> Training Data is Balanced.\n')
        h.write('--> Sigmoid function is used for the training.\n')
    else:
        h.write('--> Training Data is NOT Balanced.\n')
        if DEFINE_OneDimModel == True:
            h.write('--> Weighted Sigmoid function is used for the training.\n')
        else:
            h.write('--> Sigmoid function is used for the training.\n')
    h.write('---------------------------------------------------------------------------'+'\n')
    h.write('RNN Model hyperparameters:'+'\n')
    h.write('---------------------------------------------------------------------------'+'\n')
    h.write('Number of hidden units: '+ str(numberOfUnits)+'\n')
    h.write('Dropout coefficient: '+ str(dropCoeff)+'\n')
    h.write('Crossvalidation ratio: '+ str(testRatio)+'\n')
    h.write('Test ratio: '+ str(testRatio)+'\n')
    h.write('Learning rate: '+ str(learningRate)+'\n')
    h.write('Number of training epochs: '+ str(epochs)+'\n')
    h.write('Batch size while training: '+ str(batch_size)+'\n')
    h.write('---------------------------------------------------------------------------'+'\n')
    h.write('RNN Model Testing Accuracy:'+'\n')
    h.write('---------------------------------------------------------------------------'+'\n')
    h.write('Accuracy on test dataset: '+ str(accTest*100) + ' %'+'\n')
    h.write('---------------------------------------------------------------------------'+'\n')
    print('*****************************************************************************')
    print('Model is trained and saved under checkpoints subfolder.')
    print('*****************************************************************************')

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument( '--labeledDataPathIN', dest='labeledDataPathIN',type=str)
    parser.add_argument('--trainedModelPath', dest='trainedModelPath', type=str)
    parser.add_argument('--useTj4Training', dest='useTj4Training', type=int)
    parser.add_argument('--learningRate', dest='learningRate', type=float)
    parser.add_argument('--epochs', dest='epochs', type=int)
    parser.add_argument('--batch_size', dest='batch_size', type=int)
    parser.add_argument('--balanceData', dest='balanceData', type=int)
    parser.add_argument('--testRatio', dest='testRatio', type=float)
    parser.add_argument('--dropCoeff', dest='dropCoeff', type=float)
    parser.add_argument('--numberOfUnits', dest='numberOfUnits', type=int)
    args=parser.parse_args()
    main()   
