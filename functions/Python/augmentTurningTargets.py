# go through the hole original turning targets and generate augmented ones (don't forget to save tj also!!)
import numpy as np
from matplotlib import pyplot as plt
import glob, os
def my_data_reader(path_tofile,saveLabelPath):
    np.set_printoptions(suppress=True,
                        precision=8,
                       threshold=10000,
                       linewidth=150)
    count = 0
    my_list = []
    all_data = []
    all_lenghts = []
    os.chdir(path_tofile)
    for file in glob.glob("*.txt"):
        reader = open(file, "r")
        
        for line in reader:
            #line = line.split(',')
            my_list.append(line)
        for i, j in enumerate(my_list):
            
            if 'Label: 1' in j:
                count += 1
                print(file)
                checked = True
                tj = my_list[i-1]
                tj = tj[5:-1]
                tj = float(tj)
                
                statring_row = i+3
                label = my_list[i-3]
                print(tj)
                while checked == True:
                    f= open(saveLabelPath+'Lapelacian_'+file,"a+")
                    f.write(str(label))
                    f.write('Tj:'+str(tj)+'\n')
                    m= open(saveLabelPath+'Uniformed_'+file,"a+")
                    m.write(str(label))
                    m.write('Tj:'+str(tj)+'\n')
                    for m, n in enumerate(my_list[statring_row:]):
                        if '******-------------------------------------------------------------------------------------------------------------------******' in n:
                            checked = False
                            break
                        my_data = n.split(',')
                        my_time = my_data[0]
                        my_time = float(my_time)
                        if my_time>=tj:
                            checked = False
                            break
                        my_data = np.asarray(my_data)
                        my_data_f = my_data.astype(np.float)
                        my_data_f[np.isnan(my_data_f)] = 0
                        data_lenght = len(my_data_f)
                        npdata = np.asarray(my_data_f).reshape((data_lenght))
                        npdata = np.append(npdata,[1])
                        all_data.append(npdata)
                        original_data = ', '.join(map(str, npdata))
                        laplacian_noise = npdata + np.random.laplace(loc=0.0, scale=0.09, size=npdata.shape)
                        laplacian_noise = np.append(laplacian_noise,[1])
                        results = ', '.join(map(str, laplacian_noise))
                        uniform_noise = npdata + np.random.uniform(size=npdata.shape)
                        uniform_noise = np.append(uniform_noise,[1])
                        uniform_result = ', '.join(map(str, uniform_noise))
                        f= open(saveLabelPath+'Lapelacian_'+file,"a+")
                        f.write(results+'\n')
                        m= open(saveLabelPath+'Uniformed_'+file,"a+")
                        m.write(uniform_result+'\n')
                        
                    
                print(len(all_data))
                all_lenghts.append(len(all_data)) #calculating time_step lenght of each target
                all_data.clear()
                
                f= open(saveLabelPath+'Lapelacian_'+file,"a+")
                f.write('======='+'\n')
                m= open(saveLabelPath+'Uniformed_'+file,"a+")
                m.write('======='+'\n')            
        my_list.clear()
        reader.close()

    print (count)
    print('Maximum lenght of Targets',max(all_lenghts)) #maximum time_step lenght of all the targets we have
    print('Minimum lenght of Targets',min(all_lenghts))

saveLabelPath = ('F:\\my_augment\\EFC\\')
path_tofile = ('F:\\labeled_data_NEW\\EFC')
my_data_reader(path_tofile,saveLabelPath)













