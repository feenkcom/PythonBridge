Class {
	#name : #PBCommandQueueTest,
	#superclass : #TestCase,
	#instVars : [
		'queue',
		'app'
	],
	#category : #'PythonBridge-Tests'
}

{ #category : #initialization }
PBCommandQueueTest >> setUp [
	| execHandler |
	app := PBStubApplication new.
	execHandler := PBExecutionHandler basicNew 
							application: app;
							yourself.
	queue := LanguageLinkCommandRegistry executionHandler: execHandler
]

{ #category : #tests }
PBCommandQueueTest >> testCleaningCommand [
	| cc1 cc2 |
	cc1 := PBCommand new.
	cc2 := PBCommand new.
	queue addCommand: cc1.
	queue addCommand: cc2.
	self assert: (queue finishCommand: cc1).
	self assert: queue size equals: 1.
	self assert: (queue finishCommand: cc2).
	self assert: queue isEmpty
]

{ #category : #tests }
PBCommandQueueTest >> testEmptyQueue [
	self assert: queue isEmpty
]

{ #category : #tests }
PBCommandQueueTest >> testEnqueue [
	| c |
	c := PBCommand new.
	queue addCommand: c.
	self assert: queue size equals: 1
]

{ #category : #tests }
PBCommandQueueTest >> testFinishCommand [
	| cc |
	cc := PBCommand new.
	queue addCommand: cc.
	self assert: (queue finishCommand: cc).
	self assert: queue isEmpty
]

{ #category : #tests }
PBCommandQueueTest >> testFinishCommand2 [
	| cc |
	cc := PBCommand new.
	queue addCommand: cc.
	queue addCommand: PBCommand new.
	self assert: (queue finishCommand: cc).
	self deny: queue isEmpty
]

{ #category : #tests }
PBCommandQueueTest >> testFinishNotFoundCommand [
	self 
		should: [ queue finishCommandId: 'aa' ]
		raise: Error
]

{ #category : #tests }
PBCommandQueueTest >> testFinishOutOfSync2Command [
	| cc1 cc2 |
	cc1 := PBCommand new.
	cc2 := PBCommand new.
	queue addCommand: cc1.
	queue addCommand: cc2.
	queue finishCommand: cc2.
	queue finishCommand: cc1.
	self assert: queue isEmpty
]

{ #category : #tests }
PBCommandQueueTest >> testFinishedOutOfSequenceCommand [
	| cc1 cc2 |
	cc1 := PBCommand new.
	cc2 := PBCommand new.
	queue addCommand: cc1.
	queue addCommand: cc2.
	self assert: (queue finishCommand: cc1).
	self assert: (queue finishCommand: cc2).
	self assert: queue isEmpty
]

{ #category : #tests }
PBCommandQueueTest >> testNotFoundCommand [
	queue addCommand: PBCommand new.
	self 
		should: [ queue finishCommandId: 'aa' ]
		raise: Error
]
