from gtoolkit_bridge import gtView

class GtRemotePhlowDeclarativeTestInspectable:

	def __init__(self):
		super().__init__()
		self.collection = [42, "Lorem ipsum dolor sit amet", 3.14159, True, False, None]
		self.string = "Hello GT World !"

	def get_collection(self):
		return self.collection

	def get_string(self):
		return self.string

	@gtView
	def gtViewCollection(self, builder):
		clist = builder.columnedList()
		clist.title('Collection')
		clist.priority(25)
		clist.items(lambda: list(range(0, len(self.get_collection()))))
		clist.column('#', lambda index: index)
		clist.column('item', lambda index: str(self.get_collection()[index]))
		clist.set_accessor(lambda index: self.get_collection()[index])
		return clist

	@gtView
	def gtViewString(self, builder):
		editor = builder.textEditor()
		editor.title("String")
		editor.priority(35)
		editor.setString(self.get_string())
		return editor

	@gtView
	def gtViewError(self, builder):
		raise Exception("I'm sorry, Dave. I'm afraid I can't do that.")
		
	@gtView
	def gtViewEmpty(self, builder):
		return builder.empty()
		
	@gtView
	def gtViewCollectionForward(self, builder):
		forward = builder.forward()
		forward.title("Collection forward")
		forward.priority(30)
		forward.object(lambda: self)
		forward.view('gtViewCollection')
		return forward
