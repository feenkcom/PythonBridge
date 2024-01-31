from .phlow.view_builder import ViewBuilder

def gtView(func):
	setattr(func, "gtView", True)
	return func

class GtViewedObject:
	def __init__(self, obj):
		self.object = obj
	
	def getObject(self):
		return self.object

	def getGtViewMethodNames(self):
		# those defined by me
		allMyAttributes = dir(self)
		allMyMethods = filter(lambda each: callable(getattr(self, each, None)), allMyAttributes)
		myGtViews = filter(lambda each: getattr(getattr(self, each, None), "gtView", False), allMyMethods)
		# those defined by the object that I wrap
		allObjectAttributes = dir(self.object)
		allObjectMethods = filter(lambda each: callable(getattr(self.object, each, None)), allObjectAttributes)
		objectGtViews = filter(lambda each: getattr(getattr(self.object, each, None), "gtView", False), allObjectMethods)
		# combined into a list of strings
		result = list(myGtViews) + list(objectGtViews)
		# when I wrap a @gtView marked method I get false positives, 
		# this is normal but they are not real gtViews, remove them
		# my attribute 'object' matches because it is callable and marked
		if ('object' in result):
			result.remove('object')
		# the object's attribute '__func__' matches because it is callable and marked
		if ('__func__' in result):
			result.remove('__func__')
		return result
		
	def getView(self, viewName):
		# first see if I define it
		if (getattr(self, viewName, None) != None):
			return getattr(self, viewName)(ViewBuilder())
		# else delegate to the object that I wrap
		return getattr(self.object, viewName)(ViewBuilder())

	def getDataSource(self, viewName):
		return self.getView(viewName).dataSource()
	
	def getViewDeclaration(self, viewName):
		view = self.getView(viewName)
		exportData = view.asDictionaryForExport()
		exportData["methodSelector"] = viewName
		return exportData
		
	def getViewsDeclarations(self):
		viewNames = self.getGtViewMethodNames()
		viewDeclarations = map(lambda each: self.getViewDeclaration(each), viewNames)
		nonEmptyViewDeclarations = filter(lambda each: each["viewName"] != "empty", viewDeclarations)
		return list(nonEmptyViewDeclarations)

	def attributesFor(self, anObject, callables):
		allAttributes = dir(anObject)
		filteredAttributes = filter(lambda each: callable(getattr(anObject, each, None)) == callables, allAttributes)
		keyValuePairs = map(lambda each: [each, getattr(anObject, each, "")], filteredAttributes)
		return list(keyValuePairs)

	@gtView
	def gtViewAttributes(self, aBuilder):
		return aBuilder.columnedList()\
			.title("Attributes")\
			.priority(200)\
			.items(lambda: self.attributesFor(self.object, False))\
			.column("Name", lambda each: each[0])\
			.column("Value", lambda each: each[1])\
			.set_accessor(lambda selection: self.attributesFor(self.object, False)[selection][1])

	@gtView
	def gtViewMethods(self, aBuilder):
		return aBuilder.columnedList()\
			.title("Methods")\
			.priority(250)\
			.items(lambda: self.attributesFor(self.object, True))\
			.column("Name", lambda each: each[0])\
			.column("Value", lambda each: each[1])\
			.set_accessor(lambda selection: self.attributesFor(self.object, True)[selection][1])
			
	@gtView
	def gtViewPrint(self, aBuilder):
		return aBuilder.textEditor()\
			.title("Print")\
			.priority(300)\
			.setString(str(self.object))