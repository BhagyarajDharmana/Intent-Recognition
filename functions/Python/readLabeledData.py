
# read all labeled TFC or EFC Data and list them labeled in a single txt file
# read path should be defined once at the beginning of the function
# write path should also be defined at the beginning as a string 
# user choose between tfc or efc
# user choose between getting all data or only tj portion
# user choose between augmenting the data or not 
# naming of the output text file is dependiong on the user choices: EFC/TFC?; Augmented/Not? ; tj/all?
import numpy as np
import glob, os
import argparse
              
def readLabeledData(labeledDataPathIN,labeledDataPathOUT,useTj4Training):
    np.set_printoptions(suppress=True,precision=8,threshold=10000,linewidth=150)
    my_list = []
    all_lengths = []
    os.chdir(labeledDataPathIN)
    for f in glob.glob("*.txt"):
        reader = open(f, "r")
        for line in reader:
            my_list.append(line)
        for i, j in enumerate(my_list):
            all_lengths=storeIDLabelData(my_list,i,j,labeledDataPathOUT,useTj4Training,all_lengths)                                                   
        my_list.clear()
        reader.close()
    maxLength=max(all_lengths)
    minLength=min(all_lengths)
    print('Maximum length of Targets',maxLength) #maximum time_step length of all the targets we have
    print('Minimum length of Targets',minLength)

def storeIDLabelData(my_list,lineIdx,line, labeledDataPathOUT,useTj,all_lengths):
    nan2num=0
    inf2num=9999
    IDdata = []
    if 'Label: 1' in line or 'Label: 0' in line:
        checked = True
        tj = my_list[lineIdx-1]
        tj = tj[5:-1]
        tj = float(tj)
        statring_row = lineIdx+3
        h = open(labeledDataPathOUT,"a+")
        h.write('====='+'\n')
        for m, n in enumerate(my_list[statring_row:]):
            if '******-------------------------------------------------------------------------------------------------------------------******' in n:
                checked = False
                break
            my_data = n.split(',')
            my_time = my_data[0]
            my_time = float(my_time)
            if my_time>tj and useTj!=0:
                checked = False
                break
            my_data = np.asarray(my_data)
            my_data_f = my_data.astype(np.float)
            my_data_f[np.isnan(my_data_f)] = nan2num
            my_data_f[np.isinf(my_data_f)] = inf2num
            data_length = len(my_data_f)
            lineData = np.asarray(my_data_f).reshape((data_length))
            if 'Label: 1' in line: 
                lineData = np.append(lineData,[1])
            else:
                lineData = np.append(lineData,[0])
            IDdata.append(lineData)      
        if len(IDdata)>=10:
            h = open(labeledDataPathOUT,"a+")
            for i in range(len(IDdata)):
                line2store = ', '.join(map(str, IDdata[i]))
                h.write(line2store+'\n')
            all_lengths.append(len(IDdata))
        h.write('------------------------'+'\n')
    return all_lengths
