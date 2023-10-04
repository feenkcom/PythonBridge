class ListColumn:
	def __init__(self, title, formatCallback, width):
		self.title = title
		self.formatCallback = formatCallback
		self.width = width

	def getTitle(self):
		return self.title
	
	def formatItem(self, item):
		return self.formatCallback(item)