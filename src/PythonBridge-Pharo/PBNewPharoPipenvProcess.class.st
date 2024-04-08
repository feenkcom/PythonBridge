"
I am PBNewPharoPipenvProcess.
I am a LanguageLinkAbstractProcess.

I start Python in a subprocess running a bridge server that we can talk to.

I differ from PBPharoPipenvProcess in that I do not use source code copied over in a runtime directory.

I rely on the gtoolkit_bridge PyPI package.

I still rely on pipenv and operate in a runtime directory where I rely on a Python virtual environment.

I can install additional packages inside my Python virtual environment.

"
Class {
	#name : #PBNewPharoPipenvProcess,
	#superclass : #LanguageLinkAbstractProcess,
	#instVars : [
		'process',
		'serverDebugger',
		'started'
	],
	#category : #'PythonBridge-Pharo-Processes'
}

{ #category : #accessing }
PBNewPharoPipenvProcess class >> pipenvPath [
	^ PBPharoPipenvPathFinder pipenvPath
]

{ #category : #'start-stop' }
PBNewPharoPipenvProcess >> applicationReady [
	started := true
]

{ #category : #private }
PBNewPharoPipenvProcess >> debuggerStateChangedAction: aDAPThreadStateChanged [
	"Respond to the debugger state changed notification.
	Signal all promises that the debugger has been paused."

	aDAPThreadStateChanged isStopped ifTrue:
		[ self application notifyDebuggerPaused: serverDebugger ]
]

{ #category : #utilities }
PBNewPharoPipenvProcess >> deleteInstalledVirtualEnvironment [
	"pipenv virtual environments are just directories.
	they are named after the directory they were created in with a hash of the path to it.
	PBNewPharoPlatform>>#deleteRuntimeEnvironment is not enough to delete
	the virtual environment that is often stored somewhere else.
	to really start over, call this method first"
	
	self installedVirtualEnvironment deleteAll
]

{ #category : #accessing }
PBNewPharoPipenvProcess >> errorMessage [
	^ self stderr
]

{ #category : #accessing }
PBNewPharoPipenvProcess >> exitCode [
	^ process exitCode
]

{ #category : #accessing }
PBNewPharoPipenvProcess >> gtPackage [
	"Answer the name of the Python package where top level gt code lives as a P3GIdentifier"
	
	^ #gtoolkit_bridge asP3GI => #gtoolkit
]

{ #category : #'gt extensions' }
PBNewPharoPipenvProcess >> gtViewDetailsIn: composite [
	<gtView>
	^ composite columnedList
		title: 'Details';
		priority: 40;
		items: [ {
			{ 'running' . self isRunning }.
			{ 'started' . self hasStarted }.
			{ 'working directory' . self workingDirectory }.
			{ 'installation complete' 
				. (self workingDirectory / 'complete.log') exists
					ifTrue: [ 'yes @ ' , (self workingDirectory / 'complete.log') contents ]
					ifFalse: [ 'no' ] }.
			{ 'install log' . self workingDirectory / 'install.log' }.
			{ 'virtual environment' . self installedVirtualEnvironment asFileReference }.
			{ 'python version' . self installedPythonVersion }.
			{ 'python bridge version' 
				. self application isRunning 
					ifTrue: [ self installedPythonBridgeVersion ] 
					ifFalse: [ '' ] }.
			{ 'server address' . self settings serverSocketAddress }.
			{ 'process id'
				. (process notNil and: [ process hasProcess ])
						ifTrue: [ process process id ]
						ifFalse: [ '' ] 
				. process }.
			{ 'message format' . PBPlatform current messageBrokerStrategy methodArg }.
			{ 'debugger enabled' . self isDebuggerEnabled }.
			{ 'debug mode' . self debugMode }
		} ];
		column: 'Key' text: #first weight: 0.5;
		column: 'Value' text: #second;
		send: #last;
		actionUpdateButton
]

{ #category : #'gt extensions' }
PBNewPharoPipenvProcess >> gtViewInstalledModulesIn: composite [
	<gtView>
	^ composite columnedTree
		title: 'Modules';
		priority: 50;
		items: [ self installedModulesTree ];
		children: [ :each | each at: #dependencies ];
		column: #name text: [ :each | each at: #package_name ];
		column: #version text: [ :each | each at: #installed_version ];
		actionStencil: [ :aTab | | aptitude |
			aptitude := BrGlamorousWithDropdownAptitude
				handle: [
					BrButton new
						aptitude: BrGlamorousButtonWithIconAptitude;
						icon: BrGlamorousVectorIcons add;
						label: 'Install Python module' ]
				content: [ | moduleInstallationPane |
					moduleInstallationPane := PBModuleInstallationPane new.
					moduleInstallationPane
						acceptAction: [ :aModel :aButton | | moduleName |
							moduleName := moduleInstallationPane moduleName.
							self installModule: moduleName in: self application.
							aButton enqueueTask: (BlTaskAction new 
								action: [ aTab viewContentElement phlow update.
									aButton fireEvent: BrDropdownHideWish new]) ];
						cancelAction: [ :aModel :aButton |
							aButton enqueueTask: (BlTaskAction new 
								action: [ aButton fireEvent: BrDropdownHideWish new ]) ].
					moduleInstallationPane asElement ].			
			BrButton new
				aptitude: BrGlamorousButtonWithIconAptitude + aptitude;
				icon: BrGlamorousVectorIcons add;
				label: 'Install Python module' ];
		actionUpdateButton;
		expandAll
]

{ #category : #testing }
PBNewPharoPipenvProcess >> hasProcess [
	^ process isNotNil
]

{ #category : #testing }
PBNewPharoPipenvProcess >> hasStarted [
	^ started
]

{ #category : #initalization }
PBNewPharoPipenvProcess >> initialize [
	super initialize.
	started := false
]

{ #category : #utilities }
PBNewPharoPipenvProcess >> installModule: aModule in: aPBApplication [
	| proc args description time |
	args := OrderedCollection with: 'install'. 
	aModule ifNotNil: [ args add: aModule ].
	description := Character space join: #(pipenv) , args.
	time := Time millisecondClockValue.
	proc := self newOneShotProcess.
	proc
		arguments: args;
		errorBlock: [ self error: 'Unable to execute ' , description ].
	proc runAndWait.
	self assert: proc isSuccess.
	self workingDirectory / 'install.log' writeStreamDo: [ :out |
		out setToEnd.
		(ZnNewLineWriterStream on: out) 
			print: DateAndTime now;
			space;
			nextPutAll: description;
			space;
			print: (Time millisecondsSince: time);
			nextPutAll: 'ms';
			cr ]
]

{ #category : #utilities }
PBNewPharoPipenvProcess >> installedModules [
	| proc |
	proc := self newOneShotProcess.
	proc arguments: #( 'graph' '--json' ).
	proc errorBlock: [ self error: 'pipenv graph failed' ].
	proc runAndWait.
	self assert: proc isSuccess.
	^ NeoJSONObject fromString: proc stdout
]

{ #category : #utilities }
PBNewPharoPipenvProcess >> installedModulesTree [
	| proc |
	proc := self newOneShotProcess.
	proc arguments: #( 'graph' '--json-tree' ).
	proc errorBlock: [ self error: 'pipenv graph failed' ].
	proc runAndWait.
	self assert: proc isSuccess.
	^ NeoJSONObject fromString: proc stdout
]

{ #category : #utilities }
PBNewPharoPipenvProcess >> installedPythonBridgeVersion [
	^ self application newCommandFactory
		<< #gtoolkit_bridge asP3GI import;
		<< (#gtoolkit_bridge asP3GI => #__version__);
		sendAndWait
]

{ #category : #utilities }
PBNewPharoPipenvProcess >> installedPythonVersion [
	| proc |
	proc := self newOneShotProcess.
	proc arguments: #( 'run' 'python' '-c' 'import sys;print(sys.version)' ).
	proc errorBlock: [ self error: 'pipenv run python failed' ].
	proc runAndWait.
	self assert: proc isSuccess.
	^ proc stdout lines first
]

{ #category : #utilities }
PBNewPharoPipenvProcess >> installedVirtualEnvironment [
	| proc |
	proc := self newOneShotProcess.
	proc arguments: #( '--venv' ).
	proc errorBlock: [ self error: 'pipenv --venv failed' ].
	proc runAndWait.
	self assert: proc isSuccess.
	^ proc stdout lines first
]

{ #category : #testing }
PBNewPharoPipenvProcess >> isDebuggerEnabled [
	^ self settings serverDebugMode
]

{ #category : #testing }
PBNewPharoPipenvProcess >> isRunning [
	^ process notNil and: [ process isRunning ]
]

{ #category : #private }
PBNewPharoPipenvProcess >> newBaseProcess [
	| newProcess |
	newProcess := GtSubprocessWithInMemoryOutput new
			command: self pipenvPath fullName;
			workingDirectory: self workingDirectory fullName;
			addAllEnvVariablesFromParentWithoutOverride;
			yourself.
	^ newProcess
]

{ #category : #private }
PBNewPharoPipenvProcess >> newOneShotProcess [
	^ self newBaseProcess
		terminateOnShutdown;
		yourself
]

{ #category : #private }
PBNewPharoPipenvProcess >> newProcess [
	| proc args|
	proc := self newBaseProcess.
	args := self processArguments.
	proc
		arguments: args;
		errorBlock: [
			"Until #started has been confirmed by our application,
			errors here are considered related to startup.
			Later on, we ignore errors here are ignored,
			we assume the external process died out of our control."
			self hasStarted ifFalse: [
				self error: 'Unable to run pipenv '
					, (Character space join: args) ] ].
	^ proc
]

{ #category : #accessing }
PBNewPharoPipenvProcess >> pipenvPath [
	"Answer the to use pipenvPath.
	This may be overridden by the application settings."

	^ self settings pipenvPath ifNil: [ self class pipenvPath ]
]

{ #category : #printing }
PBNewPharoPipenvProcess >> printOn: stream [
	super printOn: stream.
	stream nextPut: $(.
	self isRunning
		ifTrue: [ stream print: self settings serverSocketAddress ]
		ifFalse: [ stream nextPutAll: 'not running' ].
	stream nextPut: $)
]

{ #category : #private }
PBNewPharoPipenvProcess >> processArguments [
	| args |
	args := OrderedCollection with: 'run' with: 'python'.
	self isDebuggerEnabled
		ifTrue: [ 
			args
				add: '-m';
				add: 'debugpy';
				add: '--listen';
				add: self settings debugSocketAddress printAddress;
				add: '--wait-for-client' ].
	args
		add: '-m';
		add: 'gtoolkit_bridge';
		add: '--port';
		add: self settings serverSocketAddress port asString;
		add: '--pharo';
		add: self settings clientSocketAddress port asString;
		add: '--method';
		add: self settings messageBrokerStrategy methodArg.
	self debugMode ifTrue: [ args add: '--log' ].
	^ args
]

{ #category : #accessing }
PBNewPharoPipenvProcess >> pythonBridgePackage [
	"Answer the name of the Python package where top level PythonBridge code lives as a P3GIdentifier"
	
	^ #gtoolkit_bridge asP3GI => #PythonBridge
]

{ #category : #'start-stop' }
PBNewPharoPipenvProcess >> start [
	started := false.
	process := self newProcess.
	process run.
	self isDebuggerEnabled ifTrue: [ self startServerDebugger]
]

{ #category : #'start-stop' }
PBNewPharoPipenvProcess >> startServerDebugger [
	"Start the debugger, tell the server to run and set up inspection on halt"

	"Give the server some time to start"
	1 second wait.
	serverDebugger := DAPPythonDebugger new 
		localRoot: self workingDirectory;
		connectTo: #[127 0 0 1] port: self settings debugSocketAddress port.
	serverDebugger announcer 
		when: DAPThreadStateChanged 
		do: [ :announcement | self debuggerStateChangedAction: announcement ]
]

{ #category : #accessing }
PBNewPharoPipenvProcess >> stderr [
	^ process stderr
]

{ #category : #accessing }
PBNewPharoPipenvProcess >> stdout [
	^ process stdout 
]

{ #category : #'start-stop' }
PBNewPharoPipenvProcess >> stop [
	process ifNil: [ ^ self ].
	process terminateAll.
	process := nil
]
