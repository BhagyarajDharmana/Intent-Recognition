# load the model from '../trained_Models'
# read the trace (path is needed) and prepare the data
# inference and get the turning propability as output
import tensorflow as tf
import numpy as np
from tensorflow.contrib import predictor
import argparse
import scipy.io

def main():
    labelTxtPath=args.labelTxtPath
    considerTj=args.considerTj
    modelFolderPath=args.modelFolderPath
    max_length=args.maxDataLength    
    reader = open(labelTxtPath)
    nan2num=0
    inf2num=9999
    IDdata = []
    my_list = []
    all_IDdata = []
    relIDs=[]
    outProb=[]
    for lines in reader:  
        my_list.append(lines)
    count = 0
    for i, j in enumerate(my_list):       
        if 'TargetID' in j:
            relevant = my_list[i+1]
            if 'Target can not be processed due to lack of Data' in relevant:
                continue
            print(j)
            relIDs.append(str(j[10:-1]))
            tj = my_list[i+2]
            tj = tj[5:-1]
            tj = float(tj)
            checked = True
            starting_row = i+6 
            while checked == True:
                for m, n in enumerate(my_list[starting_row:]):  
                    if '******-------------------------------------------------------------------------------------------------------------------******' in n: 
                        checked = False
                        break 
                    my_data = n.split(',')
                    my_time = my_data[0]
                    my_time = float(my_time)
                    if my_time> tj and considerTj != 0:
                        checked = False
                        break
                    my_data = np.asarray(my_data)
                    my_data_f = my_data.astype(np.float)
                    my_data_f[np.isnan(my_data_f)] = nan2num
                    my_data_f[np.isinf(my_data_f)] = inf2num
                    data_length = len(my_data)
                    lineData = np.asarray(my_data_f).reshape((data_length))
                    IDdata.append(lineData)
                all_IDdata.append(IDdata)     
            IDdata = []                       
    dynamicVecData_all = []
    dynamicVecData_ID = []
    modelInputData = []
    for k, l in enumerate (all_IDdata): 
        for items in l:
            dynamicVecData_ID.append(items[1:10])
        dynamicVecData_all.append(dynamicVecData_ID)
        dynamicVecData_ID = []
    for z, y in  enumerate (dynamicVecData_all):
        my_length = len(y)
        if my_length<=max_length:
            u = np.pad(y,[(0,max_length-my_length),(0,0)],mode='constant', constant_values=0)          
        else:
            u=y[-max_length:]
        modelInputData.append(u)
    modelInputData = np.asarray(modelInputData,dtype=np.float32)
    modelInputData = np.asarray(modelInputData,dtype=float)
    if modelInputData.size == 0:
        return print('No relevant Targets available in this trace!!')
    print('Input Data shape is: ', np.shape(modelInputData))
    with tf.Session() as sess:
        model_saver = tf.train.import_meta_graph(modelFolderPath+'\\checkpoints\\.meta')
        model_saver.restore(sess, modelFolderPath+'\\checkpoints\\')
        pred = sess.graph.get_tensor_by_name("prediction:0")
        x = sess.graph.get_tensor_by_name("meinInput:0")
        print("Model restored.")
        print('Initialized')      
        pred = sess.run(pred, feed_dict={x: modelInputData})
        #arr = []
        prob = []
        #arr = my_predict_softmax
        pred = pred.astype(float)
        for i in pred:
            for j in i:
                temp = ('%.2f' % j)
                prob.append(temp)
            print(prob)
            prob = []
    for i in range(len(relIDs)):
        outProb.append([relIDs[i],pred[i]])
    scipy.io.savemat('IDs.mat', mdict={'IDs': relIDs})
    scipy.io.savemat('prob.mat', mdict={'prob': pred}) 
    return outProb



if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument( '--labelTxtPath', dest='labelTxtPath',type=str)
    parser.add_argument('--considerTj', dest='considerTj', type=int)
    parser.add_argument('--modelFolderPath', dest='modelFolderPath', type=str)
    parser.add_argument('--maxDataLength', dest='maxDataLength', type=int)
    args=parser.parse_args()
    main()   
