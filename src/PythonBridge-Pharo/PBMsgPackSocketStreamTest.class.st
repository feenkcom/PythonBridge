Class {
	#name : #PBMsgPackSocketStreamTest,
	#superclass : #TestCase,
	#category : #'PythonBridge-Pharo-MessageBroker'
}

{ #category : #private }
PBMsgPackSocketStreamTest >> assertSerialize: anObject [
	self connectStreams: [ :serverStream :clientStream |
		clientStream nextPut: anObject.
		self assert: serverStream next equals: anObject.
		self deny: serverStream atEnd ]
]

{ #category : #private }
PBMsgPackSocketStreamTest >> connectStreams: aBlock [
	| semaphore clientSocket serverStream clientStream |
	self serverSocket: [ :serverSocket |
		semaphore := Semaphore new.
		[ 	clientSocket := serverSocket waitForAcceptFor: 10.
			semaphore signal. ] forkAt: self serverPriority.
		[	clientStream := LanguageLinkMsgPackUtils openConnectionToHost: #[ 127 0 0 1 ] port: self port.
			semaphore wait.
			[	serverStream := LanguageLinkMsgPackUtils primStreamFromSocket: clientSocket.
				aBlock 
					value: (LanguageLinkMsgPackSocketStream on: serverStream) 
					value: (LanguageLinkMsgPackSocketStream on: clientStream)
				 ]
			ensure: [ serverStream close ] ]
		ensure: [ clientStream close ]. ]
]

{ #category : #private }
PBMsgPackSocketStreamTest >> listenBacklogSize [
	"Server socket backlog size (number of pending connection waiting to be accepted)"
	
	^ 32
]

{ #category : #private }
PBMsgPackSocketStreamTest >> port [
	^ 1332
]

{ #category : #private }
PBMsgPackSocketStreamTest >> serverPriority [
	^ Processor lowIOPriority
]

{ #category : #private }
PBMsgPackSocketStreamTest >> serverSocket: aBlock [
	| serverSocket |
	[	serverSocket := self serverSocketOn: self port.
		self assert: serverSocket notNil.
		self assert: serverSocket localPort equals: self port.
		aBlock value: serverSocket]
	ensure: [ 
			serverSocket closeAndDestroy ]
]

{ #category : #private }
PBMsgPackSocketStreamTest >> serverSocketOn: port [
	| socket |
	(socket := Socket newTCP)
		setOption: 'TCP_NODELAY' value: 1;
		setOption: 'SO_SNDBUF' value: LanguageLinkMsgPackUtils socketBufferSize;
		setOption: 'SO_RCVBUF' value: LanguageLinkMsgPackUtils socketBufferSize .
	socket listenOn: port backlogSize: LanguageLinkMsgPackUtils listenBacklogSize.
	socket isValid
		ifFalse: [ self error: 'Cannot create socket on port ', port printString ].
	^ socket
]

{ #category : #private }
PBMsgPackSocketStreamTest >> socketBufferSize [
	"Size in bytes for Sockets and SocketStream IO buffers"

	^ 4096
]

{ #category : #private }
PBMsgPackSocketStreamTest >> socketStreamTimeout [
	^ 30
]

{ #category : #private }
PBMsgPackSocketStreamTest >> testAssertError [
	self should: [ self connectStreams: [ :serverStream :clientStream | 
			Error signal ] ] raise: Error.
]

{ #category : #private }
PBMsgPackSocketStreamTest >> testBidirectionality [
	self connectStreams: [ :serverStream :clientStream |
		serverStream nextPut: 'Foo'.
		clientStream nextPut: true.
		self assert: serverStream next equals: true.
		self assert: clientStream next equals: 'Foo' ]
]

{ #category : #private }
PBMsgPackSocketStreamTest >> testByteArray [
	self assertSerialize: #[ 1 23 54 ]
]

{ #category : #private }
PBMsgPackSocketStreamTest >> testConnect [
	self connectStreams: [ :serverStream :clientStream | ]
]

{ #category : #private }
PBMsgPackSocketStreamTest >> testDictionary [
	self assertSerialize: { #foo -> #(#err 4). 4 -> 16} asDictionary
]

{ #category : #private }
PBMsgPackSocketStreamTest >> testInteger [
	self assertSerialize: 3
]

{ #category : #private }
PBMsgPackSocketStreamTest >> testLargerString [
	self assertSerialize: 'pb6f6l7aqhz80ksi8i90e5iexer'
]

{ #category : #private }
PBMsgPackSocketStreamTest >> testLargerStringRaw [
	self assertSerialize: 'pb6f6l7aqhz80ksi8i90e5iexer'
]

{ #category : #private }
PBMsgPackSocketStreamTest >> testString [
	self assertSerialize: 'FooBarZork'
]
