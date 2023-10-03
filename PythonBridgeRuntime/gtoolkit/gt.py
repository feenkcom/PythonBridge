from .phlow.view_builder import ViewBuilder

class GtViewedObject:
	def __init__(self, obj):
		self.object = obj
		self.views = {}
	
	def getObject(self):
		return self.object
	
	def getGtViewMethodNames(self):
		return list(filter(lambda each: callable(getattr(self.object, each)),filter(lambda each: each.startswith("gtView"),dir(self.object)))) + ["gtViewRaw", "gtViewPrint"]

	def getView(self, viewName):
		if (viewName in self.views):
			return self.views[viewName]
		if (viewName == "gtViewRaw"):
			return self.gtViewRaw(ViewBuilder())
		if (viewName == "gtViewPrint"):
			return self.gtViewPrint(ViewBuilder())
		return getattr(self.object, viewName)(ViewBuilder())

	def getDataSource(self, viewName):
		return self.getView(viewName).dataSource()
	
	def getViewDeclaration(self, viewName):
		view = self.getView(viewName)
		exportData = view.asDictionaryForExport()
		exportData["methodSelector"] = viewName
		return exportData

	def attributesFor(self, anObject):
		return list(map(lambda each: [each, getattr(anObject, each, "")], dir(anObject)))

	def gtViewRaw(self, aBuilder):
		return aBuilder.columnedList()\
			.title("Raw (Python)")\
			.priority(9998)\
			.items(lambda: self.attributesFor(self.object))\
			.column("Item", lambda each: each[0])\
			.column("Value", lambda each: each[1])\
			.set_accessor(lambda selection: self.attributesFor(self.object)[selection-1][1])
	
	def gtViewPrint(self, aBuilder):
		return aBuilder.textEditor()\
			.title("Print (Python)")\
			.priority(9999)\
			.setString(str(self.object))

