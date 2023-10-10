Class {
	#name : #PBBinding,
	#superclass : #LanguageLinkBinding,
	#category : #'PythonBridge-Execution'
}

{ #category : #'instance creation' }
PBBinding >> pythonVariable [
	^ key asP3GI
]

{ #category : #testing }
PBBinding >> writePython3On: aStream [
	self pythonVariable writePython3On: aStream
]
