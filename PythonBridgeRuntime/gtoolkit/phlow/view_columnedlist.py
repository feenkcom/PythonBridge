from .view import View
from .data_source import GtPhlowColumnedListDataSource
from .column import ListColumn

class ColumnedListView(View):
	def __init__(self):
		super().__init__()
		self.itemsCallback = lambda : []
		self.columns = []
		self.accessor = None

	def items(self, itemsCallback):
		self.itemsCallback = itemsCallback
		return self
	
	def column(self, columnTitle, columnFormatCallback, columnWidth = None):
		tableColumn = ListColumn(columnTitle, columnFormatCallback, columnWidth)
		self.columns.append(tableColumn)
		return self

	def dataSource(self):
		return GtPhlowColumnedListDataSource(self.itemsCallback, self.columns, self.accessor)
	
	def asDictionaryForExport(self):
		exportData = super().asDictionaryForExport()
		exportData["viewName"] = "GtPhlowColumnedListViewSpecification"
		exportData["dataTransport"] = 2
		exportData["columnSpecifications"] = list(map(lambda column : {"title": column.getTitle(), "cellWidth": column.width, "type": "text", "spawnsObjects": False, "properties": []}, self.columns))
		return exportData
	