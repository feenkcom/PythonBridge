Class {
	#name : #PBObject,
	#superclass : #Object,
	#traits : 'P3GAttributeAccess + P3GCallable',
	#classTraits : 'P3GAttributeAccess classTrait + P3GCallable classTrait',
	#instVars : [
		'pythonVariable'
	],
	#category : #'PythonBridge-Core'
}

{ #category : #'instance creation' }
PBObject class >> fromProxy: aProxy [
	| obj |
	obj := self new.
	obj pythonVariable: aProxy pythonVariable.
	self assert: obj pythonClass asString = aProxy pythonVariable.
	^ obj
]

{ #category : #'instance creation' }
PBObject class >> fromPythonReference: pythonVar [
	^ super new
			pythonVariable: pythonVar;
			yourself.
]

{ #category : #'instance creation' }
PBObject class >> newPythonVar [
	^ PBPlatform current newRandomName asP3GIdentifier
]

{ #category : #initialization }
PBObject >> application [
	^ self applicationClass uniqueInstance
]

{ #category : #initialization }
PBObject >> applicationClass [
	self class == PBObject ifTrue: [ ^ PBApplication ].
	self subclassResponsibility
]

{ #category : #accessing }
PBObject >> basicCreateObjectArgs: posArgs nameArgs: nameArgs using: commandFactory [
	^ self
		basicCreateObjectExpr: (self pythonConstructor callWith: posArgs with: nameArgs asDictionary)
		using: commandFactory
]

{ #category : #accessing }
PBObject >> basicCreateObjectArgs: posArgs using: commandFactory [
	self
		basicCreateObjectArgs: posArgs
		nameArgs: Dictionary new
		using: commandFactory
]

{ #category : #accessing }
PBObject >> basicCreateObjectExpr: anExpression using: commandFactory [
	| varName |
	self isCreated ifTrue: [ ^ self ].
	varName := self newPythonVar.
	pythonVariable := varName.
	commandFactory << (self registerIdPyExpression: anExpression).
	self registerObject.
	commandFactory send
]

{ #category : #accessing }
PBObject >> basicCreateObjectUsing: commandFactory [
	self basicCreateObjectArgs: #() using: commandFactory
]

{ #category : #'as yet unclassified' }
PBObject >> createObject [
	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
PBObject >> ensureCreateObject [
	self isCreated ifFalse: [ self createObject ]
]

{ #category : #accessing }
PBObject >> id [
	^ pythonVariable name
]

{ #category : #'as yet unclassified' }
PBObject >> isCreated [
	^ pythonVariable notNil
]

{ #category : #p3generator }
PBObject >> isLanguageLinkValue [
	^ true
]

{ #category : #p3generator }
PBObject >> isPythonGenerable [
	^ true
]

{ #category : #accessing }
PBObject >> module [
	^ self applicationClass module
]

{ #category : #'instance creation' }
PBObject >> newCommandFactory [

	^ self application newCommandFactory
]

{ #category : #'instance creation' }
PBObject >> newCommandStringFactory [

	^ self application newCommandFactory
]

{ #category : #'instance creation' }
PBObject >> newPythonVar [
	^ self class newPythonVar
]

{ #category : #accessing }
PBObject >> pythonClass [
	"Return the Python class/type name that I am a mirror of.
	Fully qualified name unless it is one of the builtins."
	
	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
PBObject >> pythonClassName [
	^ self pythonClass attributeIdentifier name
]

{ #category : #'as yet unclassified' }
PBObject >> pythonConstructor [
	^ self pythonClass
]

{ #category : #'as yet unclassified' }
PBObject >> pythonRegistryExpression [
	^ #registry callWith: #()
]

{ #category : #accessing }
PBObject >> pythonVariable [
	^ pythonVariable
]

{ #category : #'as yet unclassified' }
PBObject >> registerIdPyExpression: objExpr [
	^ self pythonRegistryExpression => #register_with_id callWith: (Array with: objExpr with: self id)
]

{ #category : #'as yet unclassified' }
PBObject >> registerObject [
	self application registerObject: self
]

{ #category : #'as yet unclassified' }
PBObject >> resolveIdPyExpression [
	^ self pythonRegistryExpression => #resolve callWith: (Array with: self id)
]

{ #category : #'as yet unclassified' }
PBObject >> writePython3On: aStream [
	self assert: self isCreated.
	self resolveIdPyExpression writePython3On: aStream
]
