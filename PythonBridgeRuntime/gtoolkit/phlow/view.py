class View:
	def __init__(self):
		self.viewTitle = "Unknown"
		self.viewPriority = 1
		self.accessor = None

	def title(self, title):
		self.viewTitle = title
		return self
	
	def priority(self, priority):
		self.viewPriority = priority
		return self
	
	def getTitle(self):
		return self.viewTitle
	
	def set_accessor(self, accessor_function):
		self.accessor = accessor_function
		return self
	
	def asDictionaryForExport(self):
		return {
			"title": self.viewTitle,
			"priority": self.viewPriority
		}
