Class {
	#name : #PBApplication,
	#superclass : #LanguageLinkApplication,
	#classVars : [
		'DebugMode'
	],
	#category : #'PythonBridge-Global'
}

{ #category : #accessing }
PBApplication class >> baseApplication [
	^ PBApplication
]

{ #category : #debug }
PBApplication class >> debugMode [
	^ DebugMode ifNil: [ false ]
]

{ #category : #debug }
PBApplication class >> debugMode: bool [
	^ DebugMode := bool
]

{ #category : #initialization }
PBApplication class >> initialize [
	SessionManager default registerToolClassNamed: self name
]

{ #category : #testing }
PBApplication class >> isWorking [
	"Return true if my uniqueInstance works by evaluating 1+2 and checking the result is 3"

	^ (self do: [ :app | 
		app newCommandFactory
			<< (P3GBinaryOperator new
					left: 1;
					right: 2;
					operator: $+;
					yourself);
			sendAndWait ]) = 3
]

{ #category : #accessing }
PBApplication class >> runtimeDirectory [
	"This is the directory basename where the runtime files are located"

	^ 'PythonBridgeRuntime'
]

{ #category : #'system startup & shutdown' }
PBApplication class >> shutDown: isImageQuitting [
	isImageQuitting ifTrue: [ self stopAllInstances ]
]

{ #category : #'start-stop' }
PBApplication class >> start [
	self isRunning ifTrue: [ ^ uniqueInstance ].
	self stop.
	uniqueInstance := self new.
	uniqueInstance start.
	^ uniqueInstance
]

{ #category : #'system startup & shutdown' }
PBApplication class >> startUp: isImageStarting [
	isImageStarting ifTrue: [ self stopAllInstances ]
]

{ #category : #'system startup & shutdown' }
PBApplication class >> stopAllInstances [
	self allInstancesDo: [ :each | each stop ]
]

{ #category : #testing }
PBApplication class >> test [
	"Test and assert if my uniqueInstance isWorking"
	
	self assert: self isWorking
]

{ #category : #utils }
PBApplication >> addMapping: pythonType to: pythonFunction [
	| globals msgService |
	globals := self newCommandFactory
			<< (self pythonBridgePackage => 'bridge_globals') import;
			<< (self pythonBridgePackage => 'bridge_globals' => 'bridge_globals') call;
			sendAndWait.
	msgService := globals at: #msg_service.
	self newCommandFactory
		sendAndWait: (msgService => #addMapping
				callWith: (Array with: pythonType with: pythonFunction))
]

{ #category : #accessing }
PBApplication >> debuggerClientFor: anException [
	"Answer the debugger client to be used by the Gt Post Mortem debugger"

	^ GtPythonPostMortemDebugger new exception: anException
]

{ #category : #accessing }
PBApplication >> errorMessage [
	"Fetch the error message from the stderr stream, from the processhander"

	^ self serverStatus
]

{ #category : #accessing }
PBApplication >> evaluateSourceSequence: sourceString [
	| cf lines |
	cf := self newCommandStringFactory.
	lines := (sourceString lines collect: #trimRight) reject: #isEmpty.
	lines isEmpty ifTrue: [ ^ nil ].
	lines size = 1
		ifTrue: [
			cf resultExpression: lines first ]
		ifFalse: [
			lines last first isSeparator
				ifTrue: [ 
					cf script: (String cr join: lines) ]
				ifFalse: [
					cf script: (String cr join: lines allButLast).
					cf resultExpression: lines last ] ].
	self isRunning ifFalse: [ self start ].
	^ cf sendAndWait
]

{ #category : #accessing }
PBApplication >> gtPackage [
	^ processHandler gtPackage
]

{ #category : #initialization }
PBApplication >> initialize [
	super initialize.
	settings := PBPlatform current defaultSettings.
	self initializeHandlers.
]

{ #category : #initialization }
PBApplication >> initializeHandlers [
	loggingHandler := LanguageLinkLoggingHandler application: self.
	communicationHandler := PBCommunicationHandler application: self.
	processHandler := PBPythonHandler application: self.
	executionHandler := PBExecutionHandler application: self
]

{ #category : #utils }
PBApplication >> installModule: aModule [
	"Install the supplied module aModule"

	self processHandler installModule: aModule
]

{ #category : #'instance creation' }
PBApplication >> newCommandFactory [
	^ self executionHandler newCommandFactory
]

{ #category : #'instance creation' }
PBApplication >> newCommandStringFactory [
	^ self executionHandler newCommandStringFactory
]

{ #category : #accessing }
PBApplication >> pipenvPath [ 
	"Answer the pipenvPath to be used for this application"

	^ settings pipenvPath ifNil: [ processHandler pipenvPath ]
]

{ #category : #'start-stop' }
PBApplication >> postInitialization [
	self processHandler applicationReady
]

{ #category : #printing }
PBApplication >> printOn: aStream [
	super printOn: aStream.
	aStream << '('.
	self isRunning
		ifFalse: [
			aStream << 'not running)'.
			^ self ].
	aStream
		print: settings clientSocketAddress;
		<< ', ';
		print: settings serverSocketAddress;
		<< ')'
]

{ #category : #accessing }
PBApplication >> pythonBridgePackage [
	^ processHandler pythonBridgePackage
]

{ #category : #accessing }
PBApplication >> runtimeDirectory [
	"This is the directory basename where the runtime files are located"

	^ self class runtimeDirectory
]

{ #category : #accessing }
PBApplication >> serverPath [
	^ self pipenvPath
]

{ #category : #accessing }
PBApplication >> workingDirectory [ 

	^ settings workingDirectory ifNil: 
		[ FileLocator imageDirectory / self runtimeDirectory ]
]
