from .view import View

class TextEditorView(View):
	def __init__(self):
		super().__init__()
		self.string = ""

	def setString(self, aString):
		self.string = aString
		return self
	
	def getString(self):
		return self.string
	
	def asDictionaryForExport(self):
		exportData = super().asDictionaryForExport()
		exportData["viewName"] = "GtPhlowTextEditorViewSpecification"
		exportData["dataTransport"] = 1
		exportData["string"] = self.getString()
		return exportData