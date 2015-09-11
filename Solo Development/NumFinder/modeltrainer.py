#Case study to detect handwriting recognition for integers (trainer)
import argparse
import cPickle
from hog_support import HOG
import dataset_support as ds
from sklearn.svm import LinearSVC


ap = argparse.ArgumentParser()
ap.add_argument("-d","--dataset",required = True, help = "path to the dataset file")
ap.add_argument("-m","--model",required = True, help = "path to model")
args = vars(ap.parse_args())

(digits,target) = ds.load_digits(args["dataset"])
data = []
hog = HOG(orientations = 18,pixelspercell=(10,10),cellsperblock=(1,1),normalize=True)

for image in digits:
	image = ds.preprocess_data(image,20)
	image = ds.center_extent(image,(20,20))

	hist = hog.describe(image)
	data.append(hist)

model = LinearSVC(random_state=42)
model.fit(data,target)
f = open(args["model"],"w")
f.write(cPickle.dumps(model))
f.close()