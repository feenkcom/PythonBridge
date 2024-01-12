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
		app commandFactory
			<< (P3GBinaryOperator new
					left: 1;
					right: 2;
					operator: $+;
					yourself).
		app commandFactory send waitForValue ]) = 3
]

{ #category : #accessing }
PBApplication class >> runtimeDirectory [
	"This is the directory basename where the runtime files are located"

	^ 'PythonBridgeRuntime'
]

{ #category : #accessing }
PBApplication class >> shutdown: isImageQuitting [
	isImageQuitting ifTrue: [ self stop ]
]

{ #category : #'start-stop' }
PBApplication class >> start [
	self isRunning ifTrue: [ Error signal: 'Python bridge already running.' ].
	self stop.
	uniqueInstance := self new.
	PBCF reset.
	uniqueInstance commandFactory reset.
	uniqueInstance start.
	^ uniqueInstance
]

{ #category : #testing }
PBApplication class >> test [
	"Test and assert if my uniqueInstance isWorking"
	
	self assert: self isWorking
]

{ #category : #utils }
PBApplication >> addMapping: pythonType to: pythonFunction [
	self commandFactory 
		send: (#bridge_globals asP3GI => #msg_service => #addMapping 
						callWith: (Array with: pythonType with: pythonFunction))
]

{ #category : #accessing }
PBApplication >> commandFactory [
	^ PBCF
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
	^ cf sendAndWait
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
PBApplication >> installModule: aString [
	"Install the supplied module using `pipenv run pip install aString`"

	PBPharoPipenvProcess new installModule: aString in: self
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

{ #category : #printing }
PBApplication >> printOn: aStream [
	aStream
		<< self class name;
		<< '('.
	self isRunning
		ifFalse: [ aStream << 'not running)'.
			^ self ].
	aStream
		print: settings clientSocketAddress;
		<< ', ';
		print: settings serverSocketAddress;
		<< ')'
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
