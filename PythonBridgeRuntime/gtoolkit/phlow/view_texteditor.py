from .view import View
from .text import GtPhlowTextDataSource

class TextEditorView(View):
	def __init__(self):
		super().__init__()
		self.string = ""
		self.textFunc = None

	def setString(self, aString):
		self.string = aString
		return self
	
	def text(self, func):
		self.textFunc = func
	
	def getString(self):
		return self.string
	
	def asDictionaryForExport(self):
		exportData = super().asDictionaryForExport()
		exportData["viewName"] = "GtPhlowTextEditorViewSpecification"
		if self.textFunc is None:
			exportData["dataTransport"] = 1
			exportData["string"] = self.getString()
		else:
			exportData["dataTransport"] = 2
			exportData["dataSource"] = GtPhlowTextDataSource(self.textFunc)
		return exportData