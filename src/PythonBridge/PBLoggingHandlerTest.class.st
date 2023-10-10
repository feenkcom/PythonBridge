Class {
	#name : #PBLoggingHandlerTest,
	#superclass : #TestCase,
	#instVars : [
		'logger'
	],
	#category : #'PythonBridge-Tests'
}

{ #category : #'as yet unclassified' }
PBLoggingHandlerTest >> logs [
	^ logger logs
]

{ #category : #initialization }
PBLoggingHandlerTest >> setUp [
	logger := LanguageLinkLoggingHandler new
]

{ #category : #tests }
PBLoggingHandlerTest >> testAddLog [
	logger log: (LanguageLinkLog message: 'Foo').
	self assert: logger logs first message equals: 'Foo'
]

{ #category : #tests }
PBLoggingHandlerTest >> testErrorLog [
	logger log: (LanguageLinkLog message: 'Foo').
	self assert: logger errorLogs isEmpty.
	logger log: (LanguageLinkErrorLog message: 'Bar').
	self assert: logger errorLogs first message equals: 'Bar'.
]
