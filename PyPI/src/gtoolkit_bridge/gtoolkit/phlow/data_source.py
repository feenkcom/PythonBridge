from ...PythonBridge.object_registry import registry

class GtPhlowItemValue:
	def __init__(self, text = ""):
		self.itemText = text
		self.background = None

	def get_background(self):
		return self.background

	def set_background(self, colorDict):
		self.background = colorDict
		return self

	def get_itemText(self):
		return str(self.itemText)

	def set_itemText(self, text):
		self.itemText = text
		return self

	def asDictionaryForExport(self):
		data = {"itemText": self.get_itemText(), "valueTypeName": self.valueTypeName()}
		if (self.get_background() != None):
			data["background"] = self.get_background()
		return data

	def valueTypeName(self):
		return "item"

class GtPhlowItemErrorValue(GtPhlowItemValue):
	def background(self):
		return {"r": 1.0, "g": 0.4701857282502444, "b": 0.458455522971652}

	def valueTypeName(self):
		return "errorValue"

class GtPhlowItemTextualValue(GtPhlowItemValue):
	def valueTypeName(self):
		return "textualValue"

class GtPhlowRowValue:
	def __init__(self, values):
		self.columnValues = values

	def asDictionaryForExport(self):
		return {"columnValues": list(map(lambda each: each.asDictionaryForExport(), self.columnValues))}

class GtPhlowListingDataSource:
	def __init__(self, computation, accessor):
		self.computation = computation
		self.values = None
		self.accessor = accessor

	def rowValue(self, i):
		raise Exception("Not Implemented", "Subclasses should implement rowValue")

	def retrieveItems(self, count, startIndex):
		if (self.values == None):
			self.values = list(self.computation())
		result = []
		for i in range(startIndex - 1, min(len(self.values), startIndex + count)):
			result.append({"nodeValue": self.rowValue(i).asDictionaryForExport(), "nodeId": i})
		return result

	def retriveSentItemAt(self, index):
		return registry().proxy(self.values[index - 1] if self.accessor == None else self.accessor(index - 1))

	def flushItemsIterator(self):
		self.values = None

class GtPhlowListDataSource(GtPhlowListingDataSource):
	def __init__(self, computation, formatCallback, accessor):
		super().__init__(computation, accessor)
		self.formatCallback = formatCallback

	def rowValue(self, i):
		try:
			return GtPhlowItemTextualValue(self.formatCallback(self.values[i]))
		except Exception as ex:
			return GtPhlowItemErrorValue(str(ex))


class GtPhlowColumnedListDataSource(GtPhlowListingDataSource):
	def __init__(self, computation, columns, accessor):
		super().__init__(computation, accessor)
		self.columns = columns

	def getCellValue(self, row, column):
		try:
			return GtPhlowItemTextualValue(column.formatItem(row))
		except Exception as ex:
			return GtPhlowItemErrorValue(str(ex))

	def rowValue(self, i):
		try:
			row = self.values[i]
		except Exception as ex:
			return GtPhlowRowValue(list(map(lambda each: GtPhlowItemErrorValue(str(ex)), self.columns)))
		return self.rowValueOfRow(row)

	def rowValueOfRow(self, row):
		return GtPhlowRowValue(list(map(lambda each : self.getCellValue(row, each), self.columns)))

class GtPhlowColumnedTreeDataSource(GtPhlowColumnedListDataSource):
	def __init__(self, computation, columns, children, accessor):
		super().__init__(computation, columns, accessor)
		self.children = children

	def nodeForPath(self, path):
		current = self.values[path[0]]
		index = 1
		while (current != None and index < len(path)):
			current = list(self.children(current))[path[index]]
			index+=1
		return current

	def retriveSentItemAtPath(self, path):
		node = self.nodeForPath(path)
		return registry().proxy(node if self.accessor == None else self.accessor(node))

	def retrieveChildrenForNodeAtPath(self, path):
		result = []
		current = self.nodeForPath(path)
		nodes = list(self.children(current))
		for i in range(0, len(nodes)):
			result.append({"nodeValue": self.rowValueOfRow(nodes[i]).asDictionaryForExport(), "nodeId": i})
		return result
