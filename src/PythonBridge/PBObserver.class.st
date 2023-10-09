Class {
	#name : #PBObserver,
	#superclass : #LanguageLinkObserver,
	#traits : 'P3GCallable',
	#classTraits : 'P3GCallable classTrait',
	#category : #'PythonBridge-Execution'
}

{ #category : #testing }
PBObserver >> isPythonGenerable [
	^ true
]

{ #category : #'error handling' }
PBObserver >> pythonNotify [
	^ self pythonNotify: nil
]

{ #category : #'error handling' }
PBObserver >> pythonNotify: anObject [
	^ self callWith: (Array with: anObject)
]

{ #category : #testing }
PBObserver >> writePython3On: aStream [
	(#observer asP3GI callWith: (Array 
											with: self command id
											with: self id)) writePython3On: aStream
]
