from matplotlib import pyplot as plt
import cv2
import argparse
import numpy as np

ap = argparse.ArgumentParser()
ap.add_argument("-i","--image",required = True, help = "Path to the search image")
args = vars(ap.parse_args())

image = cv2.imread(args["image"])
cv2.imshow("image",image)

gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
cv2.imshow("gray",gray)
hist = cv2.calcHist([gray],[0],None,[256],[0,256])

#Shows the data for the color histogram for gray
plt.figure()
plt.xlabel("Bins")
plt.ylabel("# of Pixels")
plt.plot(hist)
plt.xlim([0,256])

plt.show()

#Shows the data for the color histogram for all the color bins
chans = cv2.split(image)
colors = ("b","g","r")
plt.figure()
plt.title("'Flattened' Color Histogram")
plt.xlabel("Bins")
plt.ylabel("# of Pixels")
features = []

for(chan,color) in zip(chans,colors):
	hist = cv2.calcHist([chan],[0],None,[256],[0,256])
	features.extend(hist)
	plt.plot(hist,color =color)
	plt.xlim([0,256])

print("Feature Vectors: %d" % (np.array(features).flatten().shape))

fig = plt.figure()
ax = fig.add_subplot(131)
hist = cv2.calcHist([chans[1], chans[0]],[0,1],None,[32,32],[0,256,0,256])
p = ax.imshow(hist,interpolation = "nearest")
ax.set_title("2D Hist: ")
plt.colorbar(p)

print "2D histogram shape %s, with %d values" %(hist.shape, hist.flatten().shape[0])

hist = cv2.calcHist([image],[0,1,2],None,[8,8,8],[0,256,0,256,0,256])

print "3D histogram shape: %s, with %d values" %(hist.shape, hist.flatten().shape[0])





