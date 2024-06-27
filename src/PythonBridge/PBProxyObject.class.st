Class {
	#name : #PBProxyObject,
	#superclass : #PBObject,
	#instVars : [
		'pythonClass',
		'application'
	],
	#category : #'PythonBridge-Core'
}

{ #category : #accessing }
PBProxyObject class >> pythonClass [
	"Return the Python class/type name that I am a mirror of.
	Fully qualified name unless it is one of the builtins."

	"The default is to return PBProxyObject which is no actual Python class,
	see #pythonClass:pythonVar:application:superclasses: for how this maps to me"
	
	"Subclasses can override this to request the creation of a different mirror instance"
	
	^ 'PBProxyObject'
]

{ #category : #'instance creation' }
PBProxyObject class >> pythonClass: pythonClass pythonVar: pyVar application: application superclasses: supers [
	| proxyClass proxyClasses |
	proxyClasses := (self allSubclasses
			collect: [ :each | each pythonClass -> each ]) asDictionary.
	proxyClass := proxyClasses
			at: pythonClass
			ifAbsent: [ supers
					detect: [ :sup | proxyClasses includesKey: sup ]
					ifFound: [ :sup | proxyClasses at: sup ]
					ifNone: [ PBProxyObject ] ].
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
PBProxyObject >> doesNotUnderstand: aMessage [
	"PBProxyObjects attempt to forward unimplemented messages to python with the following semantics:
	1) Unary selectors are first tried as attribute of the python object.
	2) If the attribute is a method, it is called and the value returned, otherwise the attribute value
	   is returned
	3) If a keyword message is sent, we attempt to call a method on the python object with only the first keyword as the method name and all the arguments.
	4) If any of this fails, we simply fall back to DNU 
	"

	| sel |
	sel := aMessage selector.
	[ | val method args |
	sel isKeyword
		ifTrue: [ method := aMessage selector keywords first copyWithout: $:.
			args := aMessage arguments.
			^ self callMethod: method withArgs: args ]
		ifFalse: [ val := self attributeAt: sel.
			^ ((val class == PBProxyObject or: [ val class inheritsFrom: PBProxyObject ])
				and: [ val pythonClass = 'method' ])
				ifTrue: [ self callMethod: sel ]
				ifFalse: [ val ] ] ] on: Exception do: [  ].
	^ super doesNotUnderstand: aMessage
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
	"Return the Python class/type name that I am a mirror of.
	Fully qualified name unless it is one of the builtins."
	
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
