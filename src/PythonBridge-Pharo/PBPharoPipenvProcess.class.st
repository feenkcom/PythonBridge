Class {
	#name : #PBPharoPipenvProcess,
	#superclass : #LanguageLinkAbstractProcess,
	#instVars : [
		'process',
		'environmentVariables',
		'serverDebugger',
		'pythonMainFile'
	],
	#category : #'PythonBridge-Pharo-Processes'
}

{ #category : #initialization }
PBPharoPipenvProcess class >> pipenvPath [
	^ PBPharoPipenvPathFinder pipenvPath
]

{ #category : #initialization }
PBPharoPipenvProcess class >> pipenvPath: aFileReference [
	PBPharoPipenvPathFinder pipenvPath: aFileReference
]

{ #category : #accessing }
PBPharoPipenvProcess class >> platform [
	^ PBPharoPlatform current
]

{ #category : #initialization }
PBPharoPipenvProcess class >> reset [ 
	<script>

	PipenvPath := nil.
]

{ #category : #'start-stop' }
PBPharoPipenvProcess >> debuggerStateChangedAction: aDAPThreadStateChanged [
	"Respond to the debugger state changed notification.
	Signal all promises that the debugger has been paused."

	aDAPThreadStateChanged isStopped ifTrue:
		[ self application notifyDebuggerPaused: serverDebugger ]
]

{ #category : #accessing }
PBPharoPipenvProcess >> environmentVariables [
	^ environmentVariables
]

{ #category : #accessing }
PBPharoPipenvProcess >> errorMessage [
	^ self stderr
]

{ #category : #accessing }
PBPharoPipenvProcess >> gtPackage [
	"Answer the name of the Python package where top level gt code lives"
	
	^ #gtoolkit asP3GI
]

{ #category : #testing }
PBPharoPipenvProcess >> hasProcess [
	"Answer a boolean indicating whether the receiver has a process object"

	^ process isNotNil
]

{ #category : #initialization }
PBPharoPipenvProcess >> initialize [
	super initialize.
	environmentVariables := Dictionary new.
	self setDefaultEnvironmentVariables
]

{ #category : #utilities }
PBPharoPipenvProcess >> installModule: aString in: aPBApplication [
	"Install the supplied module using `pipenv run pip install aString`"

	| proc arguments |
	arguments := { 'run' . 'pip' . 'install' . aString }.
	proc := GtSubprocessWithInMemoryOutput new
			command: self pipenvPath fullName;
			arguments: arguments;
			workingDirectory: self workingDirectory fullName;
			addAllEnvVariablesFromParentWithoutOverride;
			errorBlock: [ self error: 'Unable to install module: ' , aString asString ];
			terminateOnShutdown;
			yourself.
	environmentVariables
		associationsDo: [ :assoc | proc environmentAt: assoc key put: assoc value ].
	proc runAndWait
]

{ #category : #testing }
PBPharoPipenvProcess >> isRunning [
	^ process
		ifNil: [ false ]
		ifNotNil: [ process isRunning ]
]

{ #category : #private }
PBPharoPipenvProcess >> newProcess [
	| newProcess |
	newProcess := GtSubprocessWithInMemoryOutput new
			command: self pipenvPath fullName;
			arguments: self processArguments;
			workingDirectory: self workingDirectory fullName;
			addAllEnvVariablesFromParentWithoutOverride;
			errorBlock: [ :proc :timedOut |
				"Don't signal an error if this is a normal stop, else only log it. 
				If the process is gone, there isn't much left to do."
				process ifNotNil: [ 'Pharo server process failed unexpectedly' crTrace ] ];
			yourself.
	OSPlatform current isWindows
		ifFalse: [ newProcess terminateOnShutdown ].
	environmentVariables
		associationsDo: [ :assoc | newProcess environmentAt: assoc key put: assoc value ].
	^ newProcess
]

{ #category : #accessing }
PBPharoPipenvProcess >> pipenvPath [
	"Answer the to use pipenvPath.
	This may be overridden by the application settings."

	^ self settings pipenvPath ifNil: [ self class pipenvPath ]
]

{ #category : #accessing }
PBPharoPipenvProcess >> process [
	^ process
]

{ #category : #private }
PBPharoPipenvProcess >> processArguments [
	| args |
	args := OrderedCollection new.
	args
		add: 'run';
		add: 'python'.
	self settings serverDebugMode
		ifTrue: [ args
				addAll: {'-m'.
						'debugpy'.
						'--listen'.
						self settings debugSocketAddress printAddress.
						'--wait-for-client'} ].
	args
		add: self pythonMainFile fullName;
		add: '--port';
		add: self settings serverSocketAddress port asString;
		add: '--pharo';
		add: self settings clientSocketAddress port asString;
		add: '--method';
		add: PBPlatform current messageBrokerStrategy methodArg.
	self debugMode ifTrue: [ args add: '--log' ].
	^ args
]

{ #category : #accessing }
PBPharoPipenvProcess >> pythonMainFile [
	^ pythonMainFile ifNil: [ self workingDirectory / 'start_bridge.py' ]
]

{ #category : #accessing }
PBPharoPipenvProcess >> pythonMainFile: anObject [
	pythonMainFile := anObject
]

{ #category : #'start-stop' }
PBPharoPipenvProcess >> runProcessKiller [
	PBPharoProcessKiller new
		application: self application;
		run
]

{ #category : #initialization }
PBPharoPipenvProcess >> setDefaultEnvironmentVariables [
	environmentVariables
		at: 'LC_ALL' put: 'en_US.UTF-8';
		at: 'LANG' put: 'en_US.UTF-8';
		at: 'PIPENV_VENV_IN_PROJECT' put: '1';
		at: 'PIP_DEFAULT_TIMEOUT' put: '100'
]

{ #category : #'start-stop' }
PBPharoPipenvProcess >> start [
	process := self newProcess.

	process run.
	self settings serverDebugMode ifTrue:
		[ self startServerDebugger ].
]

{ #category : #'start-stop' }
PBPharoPipenvProcess >> startServerDebugger [
	"Start the debugger, tell the server to run and set up inspection on halt"

	"Give the server time to start"
	1 second wait.
	serverDebugger := DAPPythonDebugger new 
		localRoot: self workingDirectory;
		connectTo: #[127 0 0 1] port: self settings debugSocketAddress port.
	serverDebugger announcer 
		when: DAPThreadStateChanged 
		do: [ :announcement | self debuggerStateChangedAction: announcement ].

]

{ #category : #accessing }
PBPharoPipenvProcess >> stderr [
	"Answer the process stderr contents"

	^ process stderr
]

{ #category : #accessing }
PBPharoPipenvProcess >> stdout [ 
	"Answer the process stdout contents"

	^ process stdout
]

{ #category : #'start-stop' }
PBPharoPipenvProcess >> stop [
	process ifNil: [ ^ self ].
	[ process queryExitStatus ifNil: [ process terminateAll ]] 
		on: Error 
		do: [ :e | "Do nothing" ].
	process closeAndCleanStreams.
	process := nil.
]

{ #category : #'start-stop' }
PBPharoPipenvProcess >> stopServerDebugger [
	"Close the debugger and deregister"

	serverDebugger close.
	serverDebugger announcer unsubscribe: self debuggerStateChangedAction
]
