Class {
	#name : #PBDeserializeTest,
	#superclass : #TestCase,
	#instVars : [
		'mapper',
		'application'
	],
	#category : #'PythonBridge-Tests'
}

{ #category : #running }
PBDeserializeTest >> application [
	^ application ifNil: [ application := PBStubApplication new ]
]

{ #category : #running }
PBDeserializeTest >> deserialize: anObject [
	^ self deserializer deserialize: anObject
]

{ #category : #running }
PBDeserializeTest >> deserializer [
	^ mapper deserializer
			serializerWrapper: PBPlatform current class httpMessageBrokerClass serializer;
			yourself
]

{ #category : #running }
PBDeserializeTest >> setUp [
	super setUp.
	mapper := LanguageLinkMapperFactory forExecutionHandler: self stubExecutionHandler
]

{ #category : #running }
PBDeserializeTest >> stubExecutionHandler [
	^ PBExecutionHandler application: self application
]

{ #category : #tests }
PBDeserializeTest >> testDeserializeArray [
	self assert: (self deserialize: '[33,"foo"]') equals: #(33 'foo')
]

{ #category : #tests }
PBDeserializeTest >> testDeserializeNull [
	self assert: (self deserialize: 'null') equals: nil
]

{ #category : #tests }
PBDeserializeTest >> testDeserializeProxy [
	| proxy |
	proxy := self deserialize: '{"__pyclass__":"MyClass","__pyid__":"abcde12345"}'.
	self assert: proxy pythonClass equals: #MyClass.
	self assert: proxy application equals: self deserializer application.
	self assert: proxy application equals: self application.
	self assert: proxy pythonVariable equals: 'abcde12345' asP3GI
]

{ #category : #tests }
PBDeserializeTest >> testDeserializeProxyInArray [
	| proxy arr |
	arr := self deserialize: '[{"__pyclass__":"MyClass","__pyid__":"abcde12345"}]'.
	self assert: arr size equals: 1.
	proxy := arr first.
	self assert: proxy pythonClass equals: #MyClass.
	self assert: proxy application equals: self deserializer application.
	self assert: proxy application equals: self application.
	self assert: proxy pythonVariable equals: 'abcde12345' asP3GI
]
