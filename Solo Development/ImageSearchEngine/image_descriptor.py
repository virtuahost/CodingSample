#Class to simplify image descriptor extraction
#Used concepts from Adrian Roseborck's blog from pyimagesearch.com
import numpy as np
import cv2

class ImageDescriptor:
	def __init__(self,bins):
		#Only for the color descriptor 
		self.bins = bins

	def describeColor(self,image):
		features = []

		#Color histogram descriptor
		imageHSV = cv2.cvtColor(image,cv2.COLOR_BGR2HSV)

		#Calculate the height and the width so that we can segment the image into pieces
		#In this case we are segmenting into 5 pieces with 4 corners and a mid piece(ellipse)
		(h,w) = imageHSV.shape[:2]
		(cX,cY) = (int(w*0.5),int(h*0.5))

		segments = [(0,cX,0,cY),(0,cX,cY,h),(cX,w,0,cY),(cX,w,cY,h)]
		(aX,aY) = (int(w*0.75)/2,int(h*0.75)/2)
		eMask = np.zeros(image.shape[:2],dtype="uint8")
		cv2.ellipse(eMask,(cX,cY),(aX,aY),0,0,360,255,-1)

		#Loop over segments apply mask and extract features by segments
		for(startX,endX,startY,endY) in segments:
			cMask = np.zeros(image.shape[:2],dtype="uint8")
			cv2.rectangle(cMask,(startX,startY),(endX,endY),255,-1)
			cMask = cv2.subtract(cMask,eMask)
			#Get the histogram for color mask
			hist = self.histogram(imageHSV,cMask)
			features.extend(hist)

		return features


	def describeHu(self,image):
		features = []

		#Hu's moment descriptor
		imageGray = cv2.cvtColor(image,cv2.COLOR_BGR2GRAY)
		features = cv2.HuMoments(cv2.moments(imageGray)).flatten()
		return features

	def histogram(self,image,mask):
		# Function to calculate the histogram for the images
		hist = cv2.calcHist([image],[0,1,2],mask,self.bins,[0, 180,0, 256,0,256])
		cv2.normalize(hist,hist)
		return hist.flatten()


