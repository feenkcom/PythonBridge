from .view import View

class ForwardView(View):
	def __init__(self):
		super().__init__()
		self.objectComputation = lambda : None
		self.forwardView = None
		self.computedView = None

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

	def getDataSource(self, viewName):
		return self.computedView.dataSource()

	def getViewSpecificationForForwarding(self):
		from .view_builder import ViewBuilder
		self.computedView = getattr(self.getForwardObject(), self.getForwardView())(ViewBuilder())
		exportData = self.computedView.asDictionaryForExport()
		exportData["methodSelector"] = self.getForwardView()
		return exportData

	def asDictionaryForExport(self):
		exportData = super().asDictionaryForExport()
		exportData["viewName"] = "GtPhlowForwardViewSpecification"
		exportData["dataTransport"] = 2
		return exportData