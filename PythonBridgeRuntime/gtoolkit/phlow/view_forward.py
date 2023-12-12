from .view import View

class ForwardView(View):
	def __init__(self):
		super().__init__()
		self.objectComputation = lambda : None
		self.forwardView = None

	def object(self, objectComputation):
		self.objectComputation = objectComputation
		return self
	
	def view(self, viewName):
		self.forwardView = viewName
		return self

	def getForwardObject(self):
		return self.objectComputation()

	def getForwardView(self):
		return self.forwardView

	def dataSource(self):
		return self

	def getViewSpecificationForForwarding(self):
		forwardView = getattr(self.getForwardObject(), self.getForwardView())(ViewBuilder())
		exportData = view.asDictionaryForExport()
		exportData["methodSelector"] = self.getForwardView()
		return exportData

	def asDictionaryForExport(self):
		exportData = super().asDictionaryForExport()
		exportData["viewName"] = "GtPhlowForwardViewSpecification"
		exportData["dataTransport"] = 2
		return exportData