from .view_list import ListView
from .view_columnedlist import ColumnedListView
from .view_columnedtree import ColumnedTreeView
from .view_texteditor import TextEditorView

class ViewBuilder:
	def textEditor(self):
		return TextEditorView()
	
	def list(self):
		return ListView()
	
	def columnedList(self):
		return ColumnedListView()
	
	def columnedTree(self):
		return ColumnedTreeView()