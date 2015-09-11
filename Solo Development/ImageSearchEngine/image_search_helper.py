#The Search class is used to simplify matching the feature vectors between images
#Used concepts from Adrian Roseborck's blog from pyimagesearch.com

import numpy as np
import csv

class SearchHelper:
	def __init__(self,indexC,indexHu):
		self.indexC = indexC
		self.indexHu = indexHu

	def search(self, queryC, queryHu, returnCount=5):
		output = {}
		#Read through each row to match descriptor for each image
		#and calculate the distance metric by averaging out the value of the 2 metrics
		with open(self.indexC) as f, open(self.indexHu) as h:
			rowC = csv.reader(f)
			rowHu = csv.reader(h)
			#Loop through the two dataset feature index files and 
			#calculate the distance metric for each. Then average them out
			for (rC,rH) in zip(rowC,rowHu):
				fC = [float(x) for x in rC[1:]]
				fH = [float(x) for x in rH[1:]]

				dC = self.chi2_distance(fC,queryC)
				dH = self.chi2_distance(fH,queryHu)

				d = (dC + dH)/2

				output[rC[0]] = d
			f.close()
			h.close()
		output = sorted([(v,k) for (k,v) in output.items()])
		return output[:returnCount]

	#Chi square distance to be used for searching
	def chi2_distance(self, histA, histB, offset=1e-10):
		d = 0.5 * np.sum([((a-b)**2/(a + b + offset)) for (a,b) in zip(histA,histB)])
		return d


