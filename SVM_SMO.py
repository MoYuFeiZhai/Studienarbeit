# -*-coding:utf-8 -*-
import matplotlib.pyplot as plt
import numpy as np
import random

"""
Modified from Jack Cui's code

"""

class optStruct:
	"""
	A data structure that maintains all values that need to be manipulated
	Parameters：
		dataMatIn - data matrix
		classLabels - data label
		C - slack variable
		toler - tolerance
	"""
	def __init__(self, dataMatIn, classLabels, C, toler):
		self.X = dataMatIn
		self.labelMat = classLabels
		self.C = C
		self.tol = toler
		self.m = np.shape(dataMatIn)[0] 				#Data Matrix Rows
		self.alphas = np.mat(np.zeros((self.m,1))) 		#Initialize the alpha parameter to 0 based on the number of rows in the matrix
		self.b = 0 										#Initialize the b parameter to 0
		self.eCache = np.mat(np.zeros((self.m,2))) 		#Initialize the tiger error cache according to the number of rows in the matrix, the first column is the valid flag bit, and the second column is the actual value of the error E.

def loadDataSet(fileName):
	"""
	read data
	Parameters:
	    fileName
	Returns:
	    dataMat
	    labelMat
	"""
	dataMat = []; labelMat = []
	fr = open(fileName)
	for line in fr.readlines():                                     #Read line by line, filter out spaces, etc.
		lineArr = line.strip().split('\t')
		dataMat.append([float(lineArr[0]), float(lineArr[1])])
		labelMat.append(float(lineArr[2]))
	return dataMat,labelMat

def calcEk(oS, k):
	"""
	Calculation error
	Parameters：
		oS - data struct
		k - data indexed by k
	Returns:
	    Ek - eroor indexed by k
	"""
	fXk = float(np.multiply(oS.alphas,oS.labelMat).T*(oS.X*oS.X[k,:].T) + oS.b)
	Ek = fXk - float(oS.labelMat[k])
	return Ek

def selectJrand(i, m):
	"""
	Function description: randomly select the index value of alpha_j
	Parameters:
	    i - alpha_i index
	    m - alpha parameter num
	Returns:
	    j - alpha_j index
	"""
	j = i                                 #choose a j not equal to i
	while (j == i):
		j = int(random.uniform(0, m))
	return j

def selectJ(i, oS, Ei):
	"""
	Inner loop heuristic 2
	Parameters：
		i - the index value of the data labeled i
		oS - data structure
		Ei - Data error labeled i
	Returns:
	    j, maxK - the index value of the data labeled j or maxK
	    Ej - Data error labeled j
	"""
	maxK = -1; maxDeltaE = 0; Ej = 0 						#init
	oS.eCache[i] = [1,Ei]  									#update error cache
	validEcacheList = np.nonzero(oS.eCache[:,0].A)[0]		#Returns the index value of the data whose error is not 0
	if (len(validEcacheList)) > 1:							#There is an error that is not 0
		for k in validEcacheList:   						#Traverse to find the largest Ek
			if k == i: continue
			Ek = calcEk(oS, k)
			deltaE = abs(Ei - Ek)
			if (deltaE > maxDeltaE):						#find maxDeltaE
				maxK = k; maxDeltaE = deltaE; Ej = Ek
		return maxK, Ej										#return maxK,Ej
	else:   												#There is no error that is not 0
		j = selectJrand(i, oS.m)							#Randomly choose the index value of alpha_j
		Ej = calcEk(oS, j)
	return j, Ej

def updateEk(oS, k):
	"""
	Calculate Ek and update the error buffer
	Parameters：
		oS - data struct 
		k - the index value of the data labeled k
	Returns:
		/
	"""
	Ek = calcEk(oS, k)
	oS.eCache[k] = [1,Ek]


def clipAlpha(aj,H,L):
	"""
	prune alpha_j
	Parameters:
	    aj - alpha_j
	    H - alpha up limit 
	    L - alpha bot limit
	Returns:
	    aj - pruned aj
	"""
	if aj > H: 
		aj = H
	if L > aj:
		aj = L
	return aj

def innerL(i, oS):
	"""
	SMO Algorithm
	Parameters：
		i - the index value of the data labeled i
		oS - data struct
	Returns:
		1 - There is alpha pair change
		0 - There is not alpha pair change
	"""
	#Step 1
	Ei = calcEk(oS, i)
	#Optimize alpha and set a certain fault tolerance rate.
	if ((oS.labelMat[i] * Ei < -oS.tol) and (oS.alphas[i] < oS.C)) or ((oS.labelMat[i] * Ei > oS.tol) and (oS.alphas[i] > 0)):
		#Use inner loop heuristic 2 to select alpha_j and compute Ej
		j,Ej = selectJ(i, oS, Ei)
		#Save the aplpha value before the update, use a deep copy
		alphaIold = oS.alphas[i].copy(); alphaJold = oS.alphas[j].copy();
		#Step 2: Calculate the upper and lower bounds L and H:
		if (oS.labelMat[i] != oS.labelMat[j]):
			L = max(0, oS.alphas[j] - oS.alphas[i])
			H = min(oS.C, oS.C + oS.alphas[j] - oS.alphas[i])
		else:
			L = max(0, oS.alphas[j] + oS.alphas[i] - oS.C)
			H = min(oS.C, oS.alphas[j] + oS.alphas[i])
		if L == H: 
			print("L==H")
			return 0
		#Step 3: Calculate η:
		eta = 2.0 * oS.X[i,:] * oS.X[j,:].T - oS.X[i,:] * oS.X[i,:].T - oS.X[j,:] * oS.X[j,:].T
		if eta >= 0: 
			print("eta>=0")
			return 0
		#Step 4: Update αj:
		oS.alphas[j] -= oS.labelMat[j] * (Ei - Ej)/eta
		#Step 5: Trim αj according to the range of values:
		oS.alphas[j] = clipAlpha(oS.alphas[j],H,L)
		#Update Ej to error cache
		updateEk(oS, j)
		if (abs(oS.alphas[j] - alphaJold) < 0.00001): 
			print("alpha_j change is too small ")
			return 0
		#Step 6: Update αi:
		oS.alphas[i] += oS.labelMat[j]*oS.labelMat[i]*(alphaJold - oS.alphas[j])
		#Update Ei to error cache
		updateEk(oS, i)
		#Step 7: Update b1 and b2:
		b1 = oS.b - Ei- oS.labelMat[i]*(oS.alphas[i]-alphaIold)*oS.X[i,:]*oS.X[i,:].T - oS.labelMat[j]*(oS.alphas[j]-alphaJold)*oS.X[i,:]*oS.X[j,:].T
		b2 = oS.b - Ej- oS.labelMat[i]*(oS.alphas[i]-alphaIold)*oS.X[i,:]*oS.X[j,:].T - oS.labelMat[j]*(oS.alphas[j]-alphaJold)*oS.X[j,:]*oS.X[j,:].T
		#Step 8: Update b according to b1 and b2:
		if (0 < oS.alphas[i]) and (oS.C > oS.alphas[i]): oS.b = b1
		elif (0 < oS.alphas[j]) and (oS.C > oS.alphas[j]): oS.b = b2
		else: oS.b = (b1 + b2)/2.0
		return 1
	else: 
		return 0

def smoP(dataMatIn, classLabels, C, toler, maxIter):
	"""
	Complete Linear SMO Algorithm
	Parameters：
		dataMatIn
		classLabels
		C
		toler
		maxIter
	Returns:
		oS.b
		oS.alphas
	"""
	oS = optStruct(np.mat(dataMatIn), np.mat(classLabels).transpose(), C, toler)					#init
	iter = 0
	entireSet = True; alphaPairsChanged = 0
	while (iter < maxIter) and ((alphaPairsChanged > 0) or (entireSet)):							#Traverse the entire data set and the alpha is not updated or the maximum number of iterations is exceeded, then exit the loop
		alphaPairsChanged = 0
		if entireSet:																				#Traverse the entire data set    						
			for i in range(oS.m):        
				alphaPairsChanged += innerL(i,oS)													#SMO
				print("Entire Set Traverse: Iteration %d sample:%d, alpha changed:%d" % (iter,i,alphaPairsChanged))
			iter += 1
		else: 																						#Iterate over non-boundary values
			nonBoundIs = np.nonzero((oS.alphas.A > 0) * (oS.alphas.A < C))[0]						#Iterate over alphas that are not on bounds 0 and C
			for i in nonBoundIs:
				alphaPairsChanged += innerL(i,oS)
				print("Non Boundary Traverse :Iteration %d sample:%d, alpha changed:%d" % (iter,i,alphaPairsChanged))
			iter += 1
		if entireSet:																				#遍历一次后改为非边界遍历
			entireSet = False
		elif (alphaPairsChanged == 0):																#If alpha is not updated, compute full-sample traversal
			entireSet = True  
		print("Iteration: %d" % iter)
	return oS.b,oS.alphas 																			#Returns the b and alphas calculated by the SMO algorithm


def showClassifer(dataMat, classLabels, w, b):
	"""
	Classification result visualization
	Parameters:
		dataMat - data matrix
	    w - Line normal vector
	    b - Straight line solution
	Returns:
	    /
	"""
	#draw sample points
	data_plus = []        #Positive Sample
	data_minus = []       #Negative Sample
	for i in range(len(dataMat)):
		if classLabels[i] > 0:
			data_plus.append(dataMat[i])
		else:
			data_minus.append(dataMat[i])
	data_plus_np = np.array(data_plus)
	data_minus_np = np.array(data_minus)
	plt.scatter(np.transpose(data_plus_np)[0], np.transpose(data_plus_np)[1], s=30, alpha=0.7)   #Positive Sample Scatter Plot
	plt.scatter(np.transpose(data_minus_np)[0], np.transpose(data_minus_np)[1], s=30, alpha=0.7) #Negative Sample Scatter Plot
	#draw straight lines
	x1 = max(dataMat)[0]
	x2 = min(dataMat)[0]
	a1, a2 = w
	b = float(b)
	a1 = float(a1[0])
	a2 = float(a2[0])
	y1, y2 = (-b- a1*x1)/a2, (-b - a1*x2)/a2
	plt.plot([x1, x2], [y1, y2])
	#find support vector points
	for i, alpha in enumerate(alphas):
		if alpha > 0:
			x, y = dataMat[i]
			plt.scatter([x], [y], s=150, c='none', alpha=0.7, linewidth=1.5, edgecolor='red')
	plt.show()


def calcWs(alphas,dataArr,classLabels):
	"""
	Calculate w
	Parameters:
		dataArr
	    classLabels
	    alphas
	Returns:
	    w
	"""
	X = np.mat(dataArr); labelMat = np.mat(classLabels).transpose()
	m,n = np.shape(X)
	w = np.zeros((n,1))
	for i in range(m):
		w += np.multiply(alphas[i]*labelMat[i],X[i,:].T)
	return w

if __name__ == '__main__':
	dataArr, classLabels = loadDataSet('testSet.txt')
	b, alphas = smoP(dataArr, classLabels, 0.6, 0.001, 40)
	w = calcWs(alphas,dataArr, classLabels)
	showClassifer(dataArr, classLabels, w, b)
