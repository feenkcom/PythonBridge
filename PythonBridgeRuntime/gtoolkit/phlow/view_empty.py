from .view import View

class EmptyView(View):
	def asDictionaryForExport(self):
		return {"viewName" : "empty"}
