#The image search descriptor extractor 
#is designed to extract feature vectors from dataset
#Data is stored in a file on system. Would prefer dropbox but don't have enough space on dropbox.
#Images are going to be described by color and shape
#Shapes are going to be defined using Hu's moments
#HSV color space will be used another descriptor. Will try to extend it to CIE l.a.b.
#Used concepts from Adrian Roseborck's blog from pyimagesearch.com
#Used image dataset from http://lear.inrialpes.fr/pubs/2008/JDS08/
import cv2
import glob
from image_descriptor import ImageDescriptor

#Path to indexset for color descriptor
indexcolor = "indexdata\indexcolor.csv"

#Path to indexset for color descriptor
indexhu = "indexdata\indexhu.csv"

#Path to dataset for the images to extract features 
dataset = "dataset"

#open the indexset for future dataset feature storage'
outputc = open(indexcolor,"w")
outputh = open(indexhu,"w")

#Initialize the descriptor class
desc = ImageDescriptor((8,12,3))

#Get the images for processing
for image in glob.glob(dataset + "/*.png"):
	imageName = image[image.rfind("/") + 1:]
	imageData = cv2.imread(imageName)

	#Describe the image
	dataDescColor = desc.describeColor(imageData)
	dataDescHu = desc.describeHu(imageData)

	#Prepare data for writing into file
	dataDescColor = [str(d) for d in dataDescColor]
	dataDescHu = [str(d) for d in dataDescHu]

	#Write to file
	outputc.write("%s,%s\n" % (imageName, ",".join(dataDescColor)))
	outputh.write("%s,%s\n" % (imageName, ",".join(dataDescHu)))

outputc.close()
outputh.close()

