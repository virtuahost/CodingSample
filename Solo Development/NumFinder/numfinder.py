#Apply gaussian blur to the image and then perform edge detection using Canny
#Once contours are found using the ROI of the contours perform OTSU thresholding.
#Then predict the digit against the generated model
#Added input parameter to search for specific digit combinations
#Used Adrian Rosebrock's book to create the following code
import argparse
import cPickle
import mahotas
import cv2
from hog_support import HOG
import dataset_support as ds

ap = argparse.ArgumentParser()
ap.add_argument("-i","--image",required=True,help="image path")
ap.add_argument("-d","--digits",help="Enter digits to search")
args = vars(ap.parse_args())

modelpath = "model/model.cPickle"

model = open(modelpath).read()
model = cPickle.loads(model)

hog = HOG(orientations=18,pixelspercell=(10,10),cellsperblock=(1,1),normalize=True)
image = cv2.imread(args["image"])
gray = cv2.cvtColor(image,cv2.COLOR_BGR2GRAY)
digits = list(args["digits"])

blurred = cv2.GaussianBlur(gray,(5,5),0)
edged = cv2.Canny(blurred,30,150)
(_,cnts,_) = cv2.findContours(edged.copy(),cv2.RETR_EXTERNAL,cv2.CHAIN_APPROX_SIMPLE)

cnts = sorted([(c,cv2.boundingRect(c)[0]) for c in cnts],key = lambda x:x[1])

for (c,_) in cnts:
	(x,y,w,h) = cv2.boundingRect(c)

	if w>=7 and h>=20:
		roi = gray[y:y+h,x:x+w]
		thresh = roi.copy()
		T = mahotas.thresholding.otsu(roi)
		thresh[thresh>T] = 255
		thresh = cv2.bitwise_not(thresh)
		thresh = ds.preprocess_data(thresh,20)
		thresh = ds.center_extent(thresh,(20,20))

		cv2.imshow("Thresh",thresh)
		hist = hog.describe(thresh)
		digit = model.predict(hist)[0]
		if str(digit) in digits:			
			cv2.rectangle(image,(x,y),(x+w,y+h),(0,255,0),1)
			cv2.putText(image,str(digit),(x-10, y-10),cv2.FONT_HERSHEY_SIMPLEX,1.2,(0,255,0),2)
			cv2.imshow("Image",image)
			cv2.waitKey(0)