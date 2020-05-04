# here the training of the RNN model should be performed
# input will be the hole labeled data list
# output will be a trained model saved in '../Trained_Models'
import numpy as np
import tensorflow as tf
from tensorflow.contrib import rnn
from sklearn.model_selection import train_test_split
from sklearn.metrics import f1_score, accuracy_score, recall_score, precision_score
from sklearn.utils import shuffle

def trainLstmModel(labeledDataPathOUT, trainedModelPath,learning_rate,epochs,batch_size, balanceData,testRatio,dropCoeff,n_units):
    n_classes = 1
    n_features = 9
    strTargetsPortion=4
    all_data = []
    final_list = []
    my_list = []
    samples = []
    all_lenghts = []
    reader=open(labeledDataPathOUT)
    for lines in reader:  
        my_list.append(lines)        
    count = 0
    for i, j in enumerate(my_list):
        if '=====' in j:
            checked = True
            starting_row = i+1
            while checked == True:
                for m, n in enumerate(my_list[starting_row:]):
                    if '------------------------' in n:
                        checked = False
                        break
                    my_data = n.split(',')
                    my_data = np.asarray(my_data)
                    my_data_f = my_data.astype(np.float)
                    data_lenght = len(my_data)
                    npdata = np.asarray(my_data_f).reshape((data_lenght))
                    all_data.append(npdata)
                samples.append(all_data)    
            all_lenghts.append(len(all_data))    
            all_data = [] 
    trainingData = []
    idData = []
    finalLabel = []
    labels = []
    finalTrainingSet = []
    labelsTurn=[]
    labelsStr=[]
    trainingTurn=[]
    trainingStr=[]
    for k, l in enumerate (samples):
        if len(l)>1:
            for items in l:
                idData.append(items[1:10])            
            finalLabel = items[-1:]
            if finalLabel ==1:
               labelsTurn.append(finalLabel)
               trainingTurn.append(idData)
            else:
               labelsStr.append(finalLabel)
               trainingStr.append(idData) 
            idData = []
    allLen=[]
    if balanceData != 0:
        minLabelLength=min(len(labelsTurn),len(labelsStr))
        trainingTurn,labelsTurn=shuffle(trainingTurn,labelsTurn,random_state=0)
        trainingStr,labelsStr=shuffle(trainingStr,labelsStr,random_state=0)
        for ii in range(2*minLabelLength):
            if ii <minLabelLength:
                trainingData.append(trainingTurn[ii])
                labels.append(labelsTurn[ii])
            else:
                trainingData.append(trainingStr[ii-minLabelLength])
                labels.append(labelsStr[ii-minLabelLength])
        trainingData,labels=shuffle(trainingData,labels,random_state=0)
    else:
        for ii in range(len(labelsTurn)):
            trainingData.append(trainingTurn[ii])
            labels.append(labelsTurn[ii])
        for ii in range(len(labelsStr)/strTargetsPortion):
            trainingData.append(trainingStr[ii])
            labels.append(labelsStr[ii])
        trainingData,labels=shuffle(trainingData,labels,random_state=0)
    for mat in trainingData:
        allLen.append(len(mat))
    maxLength=max(allLen)
    minLength=min(allLen)
    for z, y in  enumerate (trainingData):
        if len(y)<=maxLength:
            u = np.pad(y,[(0,maxLength-len(y)),(0,0)],mode='constant', constant_values=0)
            finalTrainingSet.append(u)

    finalTrainingSet = np.asarray(finalTrainingSet,dtype=np.float32)
    labels = np.asarray(labels,int)
    oneHotLabels=[]
    nTurning=0
    nStraight=0
    for label in labels:
        if label==0:
            nStraight +=1
        else:
            nTurning +=1
    oneHotLabels=np.asarray(labels,int)
    print("--------------------------------------------------")
    print("Dataset X shape is: ", np.shape(finalTrainingSet))
    print("Dataset Y shape is: ", np.shape(oneHotLabels))
    print("--------------------------------------------------")
    X_train,X_test,Y_train,Y_test = train_test_split(finalTrainingSet, oneHotLabels, test_size=testRatio, shuffle=True, random_state=1)
    X_train,X_val,Y_train,Y_val = train_test_split(X_train, Y_train, test_size=testRatio, random_state=1)
    print("X_train shape: ", X_train.shape)
    print("Y_train shape: ",  Y_train.shape)
    print("--------------------------------------------------")
    print("X_val shape: " , X_val.shape)
    print("Y_val shape: " ,  Y_val.shape)
    print("--------------------------------------------------")
    print("X_test shape: " , X_test.shape)
    print("Y_test shape: " ,  Y_test.shape)
    time_steps = maxLength
    x= tf.placeholder('float32',[None,time_steps,n_features],name="meinInput")
    y = tf.placeholder('float32',[None,n_classes])
    out_weights=tf.Variable(tf.random_normal([n_units,n_classes]))
    out_bias=tf.Variable(tf.random_normal([n_classes]))
    my_input = tf.unstack(x ,time_steps,1)
    lstm_layer = rnn.BasicLSTMCell(n_units,forget_bias=1)
    lstm_layer = rnn.DropoutWrapper(lstm_layer,output_keep_prob=(1-dropCoeff))
    outputs,states=rnn.static_rnn(lstm_layer,my_input,dtype="float32")
    out=tf.matmul(outputs[-1],out_weights)+out_bias
    prediction=tf.nn.sigmoid(out,name="prediction")
    print("--------------------------------------------------")
    if balanceData ==0:
        #w=max(nStraight,nTurning)/max(min(nStraight,nTurning),1)
        w=3
        cost=tf.nn.weighted_cross_entropy_with_logits(logits=out,targets=y,pos_weight=w)
        print('training using weighted sigmoid function, pos_weight = ',w)    
    else:
        cost=tf.nn.sigmoid_cross_entropy_with_logits(logits=out,labels=y)
        print('training using normal sigmoid function')
    loss=tf.reduce_mean(cost)
    opt=tf.train.AdamOptimizer(learning_rate=learning_rate).minimize(loss)
    correct_pred=tf.equal(tf.round(prediction),y)
    accuracy=tf.reduce_mean(tf.cast(correct_pred,tf.float32))
    tf.summary.scalar("accuracy", accuracy)
    tf.summary.scalar("loss", loss)
    merge = tf.summary.merge_all()
    x_test= tf.placeholder('float32',[len(X_test),time_steps,n_features])
    y_test = tf.placeholder('float32',[len(X_test),n_classes])
    init=tf.global_variables_initializer()
    saver = tf.train.Saver()
    with tf.Session() as sess:
        sess.run(init)
        train_writer = tf.summary.FileWriter(trainedModelPath+'\\Logs\\plot_train\\', graph=sess.graph)
        val_writer = tf.summary.FileWriter(trainedModelPath+'\\Logs\\plot_val\\', graph=sess.graph)
        for epoch in range(epochs):
            epoch_loss = 0
            X_train,Y_train=shuffle(X_train,Y_train,random_state=0)
            print("--------------------------------------------------")
            print("epoch ",str(epoch+1),": ")
            print("--------------------------------------------------")
            iter=1
            n=0
            i=0
            while i<len(X_train):
                start = i
                end = i + batch_size
                if (end<=len(X_train)):
                   batch_x = np.array(X_train[start:end])
                   batch_y = np.array(Y_train[start:end])
                   size=batch_size
                else:
                   batch_x = np.array(X_train[start:])
                   batch_y = np.array(Y_train[start:])
                   size=len(X_train)-start
                batch_x=batch_x.reshape((size,time_steps,n_features))
                batch_y=batch_y.reshape((size,n_classes))
                res = sess.run(opt, feed_dict={x: batch_x, y: batch_y})
                if i>=(len(X_train)/10)*n:
                    summary= sess.run(merge, feed_dict={x: batch_x, y: batch_y})
                    train_writer.add_summary(summary, iter)
                    train_writer.flush()
                    acc=sess.run(accuracy,feed_dict={x:batch_x,y:batch_y})
                    los=sess.run(loss,feed_dict={x:batch_x,y:batch_y}) 
                    print("iter: ",iter)
                    print("Accuracy: ",acc)
                    print("Loss: ",los)
                    epoch_loss += los
                    n=n+1
                i=end
                iter=iter+1
            print("-----------------------------------------------------------------")
            if n !=0:
                print('Epoch', epoch+1, 'completed out of', epochs, 'loss:', epoch_loss/n)
            val_data = X_val.reshape((len(X_val), time_steps, n_features))
            val_label = Y_val.reshape((len(X_val), n_classes))
            summary= sess.run(merge, feed_dict={x: val_data, y: val_label})
            val_writer.add_summary(summary, epoch)
            val_writer.flush()
            print('Validation Accuracy on Epoch:',epoch+1,' is : ', sess.run(accuracy, feed_dict={x: val_data, y: val_label}))
        save_path = saver.save(sess, trainedModelPath+'\\checkpoints\\')    
        test_data = X_test.reshape((len(X_test), time_steps, n_features))
        test_label = Y_test.reshape((len(X_test), n_classes))
        accTest = sess.run(accuracy, feed_dict={x: test_data, y: test_label})
        print("----------------------------------------------------------------")
        print("Testing Accuracy:", accTest)
        print("----------------------------------------------------------------")
        return nStraight, nTurning,maxLength,minLength, accTest
    
