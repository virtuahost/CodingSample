#Uses Histogram of Oriented gradients to find features for the digits
from skimage import feature

class HOG:
	def __init__(self,orientations=9,pixelspercell = 9,cellsperblock = (3,3), normalize = False):
		self.orientations = orientations
		self.pixelspercell = pixelspercell
		self.cellsperblock = cellsperblock
		self.normalize = normalize

	def describe(self,image):
		hist = feature.hog(image, orientations = self.orientations,pixels_per_cell = self.pixelspercell,cells_per_block = self.cellsperblock, normalise = self.normalize)
		return hist