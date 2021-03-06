Class {
	#name : #PBHttpMessageBroker,
	#superclass : #PBAbstractMessageBroker,
	#instVars : [
		'server'
	],
	#category : #'PythonBridge-Pharo-MessageBroker'
}

{ #category : #accessing }
PBHttpMessageBroker class >> pythonMethodArg [
	^ 'http'
]

{ #category : #accessing }
PBHttpMessageBroker class >> serializerClass [
	^ PBNeoJsonSerializer
]

{ #category : #private }
PBHttpMessageBroker >> handleRMessage: dict [
	| msgClass |
	msgClass := self resolveMessageFromType: (dict at: #type).
	^ self handle: dict reverseMessageClass: msgClass
]

{ #category : #private }
PBHttpMessageBroker >> invalidMethod [
	^ (ZnResponse statusLine: ZnStatusLine badRequest)
		entity: (ZnEntity text: 'Bad method');
		yourself
]

{ #category : #private }
PBHttpMessageBroker >> invalidType [
	^ (ZnResponse statusLine: ZnStatusLine notFound)
		entity: (ZnEntity text: 'Invalid type');
		yourself
]

{ #category : #testing }
PBHttpMessageBroker >> isRunning [
	^ server notNil
]

{ #category : #private }
PBHttpMessageBroker >> preventTestForkedPDestroyServer [
	| env |
	env := CurrentExecutionEnvironment value.
	(env isKindOf: TestExecutionEnvironment) ifTrue: [ 
		env forkedProcesses
			remove: server process 
			ifAbsent: [  ] ]
]

{ #category : #private }
PBHttpMessageBroker >> primSendMessage: dict [
	| ans |
	ans := [ ZnEasy 
					post: self pythonUri , '/' , (dict at: #type)
					data: (ZnEntity text: (self serializer serialize: dict)) ] on: Error do: [ :err | PBCommunicationError signal: 'Request fail' ].
	ans status = 200 ifFalse: [ PBCommunicationError signal: 'Request fail' ].
	^ self serializer deserialize: ans contents
]

{ #category : #private }
PBHttpMessageBroker >> prim_handle: req [
	"Because of the nature of HTTP, answers of sync messages are not received through this method, but as 	the answers of HTTP requests. This channel is only for RMessages."
	^ req method = #POST 
		ifTrue: [ | dict ansDict handler |
			[ 
				dict := self serializer deserialize: req contents.
				handler := self handleRMessage: dict.
				ansDict := handler shouldAnswer
								ifTrue: [ handler answer encode ]
								ifFalse: [ Dictionary new ].
				^ ZnResponse ok: (ZnEntity json: (self serializer serialize: ansDict)) ] 
			on: Error 
			do: [ :e | debugMode
							ifTrue: [ e pass ]
							ifFalse: [ ZnResponse serverError: e printString  ] ] ]
		ifFalse: [ 
			self invalidMethod ]
]

{ #category : #messaging }
PBHttpMessageBroker >> sendAsyncMessage: msg [
	self primSendMessage: msg encode.
]

{ #category : #messaging }
PBHttpMessageBroker >> sendSyncMessage: msg [
	| ansDict |
	ansDict := self primSendMessage: msg encode.
	^ msg createAnswer decode: ansDict
]

{ #category : #accessing }
PBHttpMessageBroker >> setDebugMode [
	super setDebugMode.
	server ifNotNil: [ server debugMode: true ]
]

{ #category : #'start-stop' }
PBHttpMessageBroker >> start [
	server := ZnServer on: self port.
	server debugMode: debugMode.
	server start.
	self preventTestForkedPDestroyServer.
	self
		assert: server isRunning & server isListening
		description:
			('Failed to start server on port {1}. Is there one already?' format: {server port}).
	server onRequestRespond: [ :req | self prim_handle: req ]
]

{ #category : #'start-stop' }
PBHttpMessageBroker >> stop [
	server ifNotNil: [ server stop ]
]
