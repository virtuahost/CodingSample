#Trains the model from dataset of training data for digits
#Uses a Linear SVC to train the model
#Used Adrian Rosebrock's book to create the following code
import cPickle
from hog_support import HOG
import dataset_support as ds
from sklearn.svm import LinearSVC

#Path to dataset and path to save model
dataset = "dataset/digits.csv"
modelpath = "model/model.cPickle"

(digits,target) = ds.load_digits(dataset)
data = []
hog = HOG(orientations = 18,pixelspercell=(10,10),cellsperblock=(1,1),normalize=True)

for image in digits:
	image = ds.preprocess_data(image,20)
	image = ds.center_extent(image,(20,20))

	hist = hog.describe(image)
	data.append(hist)

model = LinearSVC(random_state=42)
model.fit(data,target)
f = open(modelpath,"w")
f.write(cPickle.dumps(model))
f.close()