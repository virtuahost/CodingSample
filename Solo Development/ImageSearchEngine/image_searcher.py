#The image searcher script is used to find images that are closest to the image provided for search.
#Need to extend the code for scalability using bags of words model
#Used concepts from Adrian Roseborck's blog from pyimagesearch.com

import cv2
from image_search_helper import SearchHelper
from image_descriptor import ImageDescriptor

ap = argparse.ArgumentParser()
ap.add_argument("-i","--image",required = true,"Path to the search image")
arg = vars(ap.parse_args())

#Path to indexset for color descriptor
indexcolor = "indexdata\indexcolor.csv"

#Path to indexset for color descriptor
indexhu = "indexdata\indexhu.csv"

#Path to dataset for the images to extract features 
dataset = "dataset"

#Initialize the descriptor class
desc = ImageDescriptor((8,12,3))

#read query image and extract features
image = cv2.imread(arg["image"])
dataDescColor = desc.describeColor(imageData)
dataDescHu = desc.describeHu(imageData)

#Initialize the SearchHelper and perform search
sHelper = SearchHelper(indexcolor,indexhu)
output = sHelper.search(dataDescColor,dataDescHu)

cv2.imshow("Input image",image)

for (s,r) in output:
	img = cv2.imread(dataset+"/"+r)
	cv2.imshow("Results",img)
	cv2.waitKey(0)
