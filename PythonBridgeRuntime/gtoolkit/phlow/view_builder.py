from .view_list import ListView
from .view_columnedlist import ColumnedListView
from .view_columnedtree import ColumnedTreeView
from .view_texteditor import TextEditorView
from .view_forward import ForwardView
from .view_empty import EmptyView

class ViewBuilder:
	def textEditor(self):
		return TextEditorView()

	def list(self):
		return ListView()

	def columnedList(self):
		return ColumnedListView()

	def columnedTree(self):
		return ColumnedTreeView()

	def forward(self):
		return ForwardView()

	def empty(self):
		return EmptyView()