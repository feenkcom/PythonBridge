Class {
	#name : #PBPythonObjectTest,
	#superclass : #PBApplicationTest,
	#category : #'PythonBridge-Tests'
}

{ #category : #tests }
PBPythonObjectTest >> setUp [
	super setUp.
	self cf << (self app pythonBridgePackage => #object_registry) import
]

{ #category : #tests }
PBPythonObjectTest >> stubPythonObjectExpression [
	"Return a Python expression that gives us a Python object that we can use for testing purposes.
	It could be any object, but we use the gobal Registry since we know that exists."
	
	^ self app pythonBridgePackage => #object_registry => #Registry callWith: #()
]

{ #category : #tests }
PBPythonObjectTest >> testProxyIdentity [
	| obj |
	self cf << self stubPythonObjectExpression.
	obj := self cfSend waitForValue.
	self assert: obj class equals: PBProxyObject.
	self assertInstanceClass: obj name: 'Registry'.
	self cf << (self resolveId: obj id).
	self assert: self cfSend waitForValue equals: obj
]

{ #category : #tests }
PBPythonObjectTest >> testSimpleObjectIdentity [
	| obj |
	obj := PBObject new 
		basicCreateObjectExpr: self stubPythonObjectExpression
		using: self cf.
	self cf << obj.
	self assert: self cfSend waitForValue equals: obj.
	self assertExpression: (self resolveId: obj id) equals: obj
]

{ #category : #tests }
PBPythonObjectTest >> testSimpleProxy [
	| obj |
	self cf << self stubPythonObjectExpression.
	obj := self cfSend waitForValue.
	self assert: obj class equals: PBProxyObject.
	self assertInstanceClass: obj name: 'Registry'.
	self assertExpression: (obj => #hasId callWith: #(0)) equals: false
]
