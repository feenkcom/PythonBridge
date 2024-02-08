from .phlow.view_builder import ViewBuilder
from .phlow.view_error import ErrorView


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
        allObjectMethods = list(filter(lambda each: callable(getattr(self.object, each, None)), allObjectAttributes))
        objectGtViews = filter(lambda each: getattr(getattr(self.object, each, None), "gtView", False),
                               allObjectMethods)
        # for now, we keep the old prefix matching, avoiding doubles
        objectGtViews = set(objectGtViews)
        objectGtViews.update(filter(lambda each: each.startswith("gtView"), allObjectMethods))
        # combined into a list of strings
        result = list(set(list(myGtViews) + list(objectGtViews)))
        # when I wrap a @gtView marked method I get false positives,
        # this is normal but they are not real gtViews, remove them
        # my attribute 'object' matches because it is callable and marked
        if 'object' in result:
            result.remove('object')
        # the object's attribute '__func__' matches because it is callable and marked
        if '__func__' in result:
            result.remove('__func__')
        return result

    def getView(self, viewName):
        myView = getattr(self, viewName, None)
        objectView = getattr(self.object, viewName, None)
        if objectView is not None:
            return objectView(ViewBuilder())
        if myView is not None:
            return myView(ViewBuilder())
        raise Exception(f"Cannot find view {viewName}")

    def getDataSource(self, viewName):
        return self.getView(viewName).dataSource()

    def getViewDeclaration(self, viewName):
        try:
            view = self.getView(viewName)
            exportData = view.asDictionaryForExport()
        except Exception as err:
            view = ErrorView()
            view.set_errorMessage(str(err))
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
        return aBuilder.columnedList() \
            .title("Raw") \
            .priority(200) \
            .items(lambda: self.attributesFor(self.object, False)) \
            .column("Name", lambda each: each[0]) \
            .column("Value", lambda each: each[1]) \
            .set_accessor(lambda selection: self.attributesFor(self.object, False)[selection][1])

    @gtView
    def gtViewMethods(self, aBuilder):
        return aBuilder.columnedList() \
            .title("Methods") \
            .priority(250) \
            .items(lambda: self.attributesFor(self.object, True)) \
            .column("Name", lambda each: each[0]) \
            .column("Value", lambda each: each[1]) \
            .set_accessor(lambda selection: self.attributesFor(self.object, True)[selection][1])

    @gtView
    def gtViewPrint(self, aBuilder):
        return aBuilder.textEditor() \
            .title("Print") \
            .priority(300) \
            .setString(str(self.object))

    @gtView
    def gtViewList(self, aBuilder):
        if type(self.object) is not list:
            return aBuilder.empty()
        return aBuilder.list()\
            .title("Items")\
            .priority(150)\
            .items(lambda: self.object)\
            .itemFormat(lambda each: str(each))

    @gtView
    def gtViewTuple(self, aBuilder):
        if type(self.object) is not tuple:
            return aBuilder.empty()
        return aBuilder.list()\
            .title("Items")\
            .priority(150)\
            .items(lambda: self.object)\
            .itemFormat(lambda each: str(each))

    @gtView
    def gtViewRange(self, aBuilder):
        if type(self.object) is not range:
            return aBuilder.empty()
        return aBuilder.list()\
            .title("Range")\
            .priority(150)\
            .items(lambda: list(self.object))\
            .itemFormat(lambda each: str(each))

    @gtView
    def gtViewSet(self, aBuilder):
        if type(self.object) is not set:
            return aBuilder.empty()
        return aBuilder.list()\
            .title("Set")\
            .priority(150)\
            .items(lambda: list(self.object))\
            .itemFormat(lambda each: str(each))

    @gtView
    def gtViewInteger(self, aBuilder):
        if type(self.object) is not int:
            return aBuilder.empty()
        return aBuilder.textEditor()\
            .title("Integer")\
            .priority(150)\
            .setString(str(self.object))
 
    @gtView
    def gtViewFloat(self, aBuilder):
        if type(self.object) is not float:
            return aBuilder.empty()
        return aBuilder.textEditor()\
            .title("Float")\
            .priority(150)\
            .setString(str(self.object))

    @gtView
    def gtViewString(self, aBuilder):
        if type(self.object) is not str:
            return aBuilder.empty()
        return aBuilder.textEditor()\
            .title("String")\
            .priority(150)\
            .setString(str(self.object))

    @gtView
    def gtViewBoolean(self, aBuilder):
        if type(self.object) is not bool:
            return aBuilder.empty()
        return aBuilder.textEditor()\
            .title("Boolean")\
            .priority(150)\
            .setString(str(self.object))

    @gtView
    def gtViewDict(self, aBuilder):
        if type(self.object) is not dict:
            return aBuilder.empty()
        return aBuilder.columnedList()\
            .title("Items")\
            .priority(150)\
            .items(lambda: self.object.items())\
            .column("Key", lambda each: each[0])\
            .column("Value", lambda each: each[1])
