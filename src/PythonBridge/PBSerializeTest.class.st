Class {
	#name : #PBSerializeTest,
	#superclass : #TestCase,
	#instVars : [
		'mapper'
	],
	#category : #'PythonBridge-Tests'
}

{ #category : #accessing }
PBSerializeTest >> application [
	^ PBApplication uniqueInstance
]

{ #category : #tests }
PBSerializeTest >> serializer [
	^ mapper serializer
			serializerWrapper: PBPlatform current class httpMessageBrokerClass serializer;
			yourself
]

{ #category : #tests }
PBSerializeTest >> setUp [
	| execHandler app |
	super setUp.
	app := PBStubApplication new.
	execHandler := PBExecutionHandler basicNew
			application: app;
			yourself.
	mapper := LanguageLinkMapperFactory forExecutionHandler: execHandler
]

{ #category : #accessing }
PBSerializeTest >> settings [
	^ PBPlatform current defaultSettings
]

{ #category : #tests }
PBSerializeTest >> testSerializeArray [
	self assert: (self serializer serialize: #(33 'foo')) equals: '[33,"foo"]'
]

{ #category : #tests }
PBSerializeTest >> testSerializeNil [
	self assert: (self serializer serialize: nil) equals: 'null'
]
