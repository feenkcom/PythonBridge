Class {
	#name : #PBDeserializer,
	#superclass : #LanguageLinkDeserializer,
	#category : #'PythonBridge-Serialization'
}

{ #category : #'instance creation' }
PBDeserializer class >> deserialize: anObject [
	^ self new
		deserialize: anObject
]

{ #category : #'private protocol' }
PBDeserializer >> buildProxyFor: rawObject [
	| proxy |
	proxy :=  PBProxyObject 
					pythonClass: (rawObject at: #__pyclass__)
					pythonVar: (rawObject at: #__pyid__) asP3GI
					application: self application.
	self executionHandler registerObject: proxy.
	^ proxy
]

{ #category : #'private protocol' }
PBDeserializer >> privateDeserialize: rawObj [
	rawObj isCollection ifFalse: [ ^ rawObj ].
	rawObj isDictionary and: [ (rawObj includesKey: #__pyid__) 
		ifTrue: [ ^ self reifyProxyFor: rawObj ] ].
	^ rawObj collect: [ :elem | self privateDeserialize: elem ]
]

{ #category : #'private protocol' }
PBDeserializer >> reifyProxyFor: rawObj [
	^ self objectRegistry resolve: (rawObj at: #__pyid__) ifAbsent: [ self buildProxyFor: rawObj ]
]
