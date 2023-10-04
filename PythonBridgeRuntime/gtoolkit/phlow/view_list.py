from .view import View
from .data_source import GtPhlowListDataSource

class ListView(View):
	def __init__(self):
		super().__init__()
		self.itemsCallback = lambda : []
		self.itemsFormatCallback = lambda item: str(item)
		self.accessor = None

	def items(self, itemsCallback):
		self.itemsCallback = itemsCallback
		return self
	
	def itemFormat(self, itemFormatCallback):
		self.itemsFormatCallback = itemFormatCallback
		return self

	def dataSource(self):
		return GtPhlowListDataSource(self.itemsCallback, self.itemsFormatCallback, self.accessor)
	
	def asDictionaryForExport(self):
		exportData = super().asDictionaryForExport()
		exportData["viewName"] = "GtPhlowListViewSpecification"
		exportData["dataTransport"] = 2
		return exportData
