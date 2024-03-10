Class {
	#name : #PBProxyObject,
	#superclass : #PBObject,
	#instVars : [
		'pythonClass',
		'application'
	],
	#category : #'PythonBridge-Core'
}

{ #category : #'instance creation' }
PBProxyObject class >> pythonClass: pythonClass pythonVar: pyVar application: application [
	| proxyClass |

	proxyClass := self allSubclasses
		detect: [ :each | each pythonClass = pythonClass ]
		ifNone: [ self ].
	^ proxyClass new
		pythonVariable: pyVar;
		pythonClass: pythonClass;
		application: application;
		yourself
]

{ #category : #accessing }
PBProxyObject >> application [
	^ application
]

{ #category : #accessing }
PBProxyObject >> application: anObject [
	application := anObject
]

{ #category : #accessing }
PBProxyObject >> applicationClass [
	^ self application class
]

{ #category : #converting }
PBProxyObject >> asJsonDictionary [
	"Answer the receiver as a Dictionary"

	^ { 
		#__pyclass__ -> pythonClass.
		#__pyid__ -> pythonVariable name } asDictionary.
]

{ #category : #accessing }
PBProxyObject >> attributeAt: attributeName [
	"Answer the value of the named attribute in the Python object that I represent"

	^ self newCommandFactory
		<< (self => attributeName);
		sendAndWait
]

{ #category : #accessing }
PBProxyObject >> callMethod: methodName [
	"Call methodName on the Python object that I represent and return the result"

	^ self callMethod: methodName withArgs: #()
]

{ #category : #accessing }
PBProxyObject >> callMethod: methodName withArgs: arguments [
	"Call methodName with arguments on the Python object that I represent and return the result"

	^ self newCommandFactory
		<< (self => methodName callWith: arguments);
		sendAndWait
]

{ #category : #hooks }
PBProxyObject >> createObject [
	self shouldNotImplement
]

{ #category : #accessing }
PBProxyObject >> languageLinkSerializable [
	^ self asJsonDictionary
]

{ #category : #printing }
PBProxyObject >> printOn: str [
	str 
		<< (pythonClass asString first isVowel ifTrue: ['an '] ifFalse: ['a ']);
		<< pythonClass asString;
		<< ' (Proxy)'
]

{ #category : #accessing }
PBProxyObject >> pythonClass [
	^ pythonClass
]

{ #category : #accessing }
PBProxyObject >> pythonClass: anObject [
	pythonClass := anObject
]

{ #category : #accessing }
PBProxyObject >> pythonVariable: pyVar [
	pythonVariable := pyVar
]
