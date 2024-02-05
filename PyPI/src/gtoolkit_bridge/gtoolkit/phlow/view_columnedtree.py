from .view_columnedlist import ColumnedListView
from .data_source import GtPhlowColumnedTreeDataSource
from .column import ListColumn


class ColumnedTreeView(ColumnedListView):
	def __init__(self):
		super().__init__()
		self.childrenComputation = lambda each: []

	def children(self, children):
		self.childrenComputation = children
		return self

	def dataSource(self):
		return GtPhlowColumnedTreeDataSource(self.itemsCallback, self.columns, self.childrenComputation, self.accessor)
	
	def asDictionaryForExport(self):
		exportData = super().asDictionaryForExport()
		exportData["viewName"] = "GtPhlowColumnedTreeViewSpecification"
		return exportData
	