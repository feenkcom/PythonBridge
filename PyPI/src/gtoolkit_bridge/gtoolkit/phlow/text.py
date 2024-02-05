from typing import Any


class GtText:
	def __init__(self, string):
		self.string = string
		self.runs = []

	def range(self, start, end):
		return GtPhlowTextRun(self, start, end)
	
	def applyAttributes(self, run, attributes):
		self.runs.append((run, attributes))

	def asDictionaryForExport(self):
		attributedRuns = list(map(lambda attributedRun: {
			"__typeLabel": "phlowTextRunWithAttributes", 
			"run": attributedRun[0].asDictionaryForExport(), 
			"attributes": list(map(lambda each: each.asDictionaryForExport(), attributedRun[1]))}, self.runs))
		return { "__typeLabel": "remotePhlowTextAttributeRunsStylerSpecification", "attributedRuns": attributedRuns }

class GtPhlowTextRun:
	def __init__(self, text, start, end):
		self.text = text
		self.start = start
		self.end = end

	def asDictionaryForExport(self):
		return [self.start, self.end]

	def range(self, start, end):
		return self.text.range(start, end)

	def background(self, color):
		self.text.applyAttributes(self, [GtPhlowTextBackgroundAttribute(color)])
		return self

	def bold(self):
		self.text.applyAttributes(self, [GtPhlowTextFontWeightAttribute("bold")])
		return self
	
	def fontName(self, name):
		self.text.applyAttributes(self, [GtPhlowTextFontNameAttribute(name)])
		return self
	
	def fontSize(self, size):
		self.text.applyAttributes(self, [GtPhlowTextFontSizeAttribute(size)])
		return self

	def foreground(self, color):
		self.text.applyAttributes(self, [GtPhlowTextForegroundAttribute(color)])
		return self

	def highlight(self, color):
		self.text.applyAttributes(self, [GtPhlowTextHighlightAttribute(color)])
		return self

class GtPhlowTextAttribute:
	pass

class GtPhlowTextBackgroundAttribute(GtPhlowTextAttribute):
	def __init__(self, color):
		self.color = color

	def asDictionaryForExport(self):
		return { "__typeLabel": "phlowTextBackgroundAttribute", "color": self.color.asDictionaryForExport() }

class GtPhlowTextFontWeightAttribute(GtPhlowTextAttribute):
	def __init__(self,weight):
		self.weight = weight

	def asDictionaryForExport(self):
		return { "__typeLabel": "phlowTextFontWeightAttribute", "weight": self.weight }

class GtPhlowTextFontNameAttribute(GtPhlowTextAttribute):
	def __init__(self,name):
		self.name = name

	def asDictionaryForExport(self):
		return { "__typeLabel": "phlowTextFontNameAttribute", "name": self.name }

class GtPhlowTextFontSizeAttribute(GtPhlowTextAttribute):
	def __init__(self,size):
		self.size = size

	def asDictionaryForExport(self):
		return { "__typeLabel": "phlowTextFontSizeAttribute", "size": self.size }

class GtPhlowTextForegroundAttribute(GtPhlowTextAttribute):
	def __init__(self, color):
		self.color = color

	def asDictionaryForExport(self):
		return { "__typeLabel": "phlowTextForegroundAttribute", "color": self.color.asDictionaryForExport() }

class GtPhlowTextHighlightAttribute(GtPhlowTextAttribute):
	def __init__(self, color):
		self.color = color

	def asDictionaryForExport(self):
		return { "__typeLabel": "phlowTextHighlightAttribute", "color": self.color.asDictionaryForExport() }

class GtPhlowColor:
	pass

class GtPhlowNamedColor(GtPhlowColor):
	def __init__(self, name):
		self.name = name

	def asDictionaryForExport(self):
		return { "name": self.name }

class GtPhlowARGBDColor(GtPhlowColor):
	def __init__(self, r = 0, g = 0, b = 0, a = 255):
		self.r = r
		self.g = g
		self.b = b
		self.a = a

	def asDictionaryForExport(self):
		return { "a": self.a, "r": self.r, "g": self.g, "b": self.b }

class GtColorClass:
	def rgb(self, r, g, b):
		return GtPhlowARGBDColor(r = r, g = g, b = b)
	
	def argb(self, a, r, g, b):
		return GtPhlowARGBDColor(a = a, r = r, g = g, b = b)
	
	def __getattr__(self, name):
		return GtPhlowNamedColor(name)
	
GtColor = GtColorClass()