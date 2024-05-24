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
		'started',
		'monitorProcess',
		'stdoutStream',
		'stderrStream'
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
PBNewPharoPipenvProcess >> copyEnvVarsTo: command [
	| envVars |
	envVars := Dictionary new.
	Smalltalk os environment asDictionary
		keysAndValuesDo: [ :key :value | envVars at: key ifAbsentPut: value ].
	command clearEnv.
	envVars keysAndValuesDo: [ :key :value | command setEnv: key value: value ]
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
	
	self installedVirtualEnvironment asFileReference deleteAll
]

{ #category : #utilities }
PBNewPharoPipenvProcess >> deleteRuntimeEnvironment [
	"Delete the whole PythonBridgeRuntime working directory.
	This will effectively force reinstallation on the next run.
	Only execute when you have not added or editing anything there"
	
	self workingDirectory deleteAll
]

{ #category : #accessing }
PBNewPharoPipenvProcess >> errorMessage [
	^ self stderr
]

{ #category : #accessing }
PBNewPharoPipenvProcess >> exitCode [
	^ process tryWait ifNotNil: [ :status | status code ]
]

{ #category : #'gt extensions' }
PBNewPharoPipenvProcess >> gtDeleteActionFor: anAction [
	<gtAction>
	^ anAction button
		icon: BrGlamorousVectorIcons remove;
		tooltip: 'Delete the runtime environment';
		priority: 25;
		action: [ :element | self deleteRuntimeEnvironment ]
]

{ #category : #'gt extensions' }
PBNewPharoPipenvProcess >> gtDeleteVirtualEnvironmentActionFor: anAction [
	<gtAction>
	^ anAction button
		icon: BrGlamorousVectorIcons remove;
		tooltip: 'Delete the installed virtual environment';
		priority: 30;
		action: [ :element | self deleteInstalledVirtualEnvironment ]
]

{ #category : #'gt extensions' }
PBNewPharoPipenvProcess >> gtLinkActionFor: anAction [
	<gtAction>
	^ anAction button
		icon: BrGlamorousVectorIcons add;
		tooltip: 'Link gtoolkit_bridge PyPI sources';
		priority: 20;
		action: [ :element | self linkGToolkitBridgePyPISources ]
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
				. (process notNil and: [ process isRunning ])
						ifTrue: [ process id ]
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
		contextItemLabel: 'Uninstall' 
			action: [ :element :item | | moduleName |
				moduleName := item value at: #package_name.
				self uninstallModule: moduleName in: self application.
				element enqueueTask: (BlTaskAction new 
					action: [ element parent parent parent phlow update ]) ];
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
	stdoutStream := String new writeStream.
	stderrStream := String new writeStream.
	started := false
]

{ #category : #utilities }
PBNewPharoPipenvProcess >> installModule: aModule in: aPBApplication [
	| builder  args description time output  |
	args := OrderedCollection with: 'install'. 
	aModule ifNotNil: [ args add: aModule ].
	description := Character space join: #(pipenv) , args.
	time := Time millisecondClockValue.
	builder := self newExternalProcessBuilder.
	builder arguments: args.
	output := self waitForProcessAsync: builder.
	self assert: output status isSuccess.
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
	| builder output  |
	builder := self newExternalProcessBuilder.
	builder arguments: #( 'graph' '--json' ).
	output := self waitForProcessAsync: builder.
	self assert: output status isSuccess.
	^ NeoJSONObject fromString: output stdout
]

{ #category : #utilities }
PBNewPharoPipenvProcess >> installedModulesTree [
	| builder output  |
	builder := self newExternalProcessBuilder.
	builder arguments: #( 'graph' '--json-tree' ).
	output := self waitForProcessAsync: builder.
	self assert: output status isSuccess.
	^ NeoJSONObject fromString: output stdout
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
	| builder output  |
	builder := self newExternalProcessBuilder.
	builder arguments: #( 'run' 'python' '-c' 'import sys;print(sys.version)' ).
	output := self waitForProcessAsync: builder.
	self assert: output status isSuccess.
	^ output stdout lines first
]

{ #category : #utilities }
PBNewPharoPipenvProcess >> installedVirtualEnvironment [
	| builder output  |
	builder := self newExternalProcessBuilder.
	builder arguments: #( '--venv' ).
	output := self waitForProcessAsync: builder.
	self assert: output status isSuccess.
	^ output stdout lines first
]

{ #category : #testing }
PBNewPharoPipenvProcess >> isDebuggerEnabled [
	^ self settings serverDebugMode
]

{ #category : #testing }
PBNewPharoPipenvProcess >> isRunning [
	^ process notNil and: [ process isRunning ]
]

{ #category : #utilities }
PBNewPharoPipenvProcess >> linkGToolkitBridgePyPISources [
	"To work on the gtoolkit_bridge sources themselves, create a symbolic link
	from the working directory to the PyPI git sources, which assumes GT in dev mode.
	You have to restart the bridge so that this code gets picked up."

	| pyPI bridgeRuntime exitCode |
	pyPI := FileLocator gtResource / 'feenkcom' / 'PythonBridge' / 'PyPI' / 'src' / 'gtoolkit_bridge'.
	self assert: pyPI exists.
	bridgeRuntime := self workingDirectory.
	(bridgeRuntime / 'gtoolkit_bridge') exists
		ifFalse: [
			exitCode := LibC runCommand: 'cd ' , bridgeRuntime fullName , ' && ln -s ' , pyPI fullName.
			self assert: exitCode isZero ]
]

{ #category : #private }
PBNewPharoPipenvProcess >> monitorProcess [
	"This runs alongside the native process"
	| status |
	process waitForExitDoing: [ self pollStdoutAndStderr ].
	status := process ifNotNil: [ process tryWait ].
	"Until #started has been confirmed by our application, errors here are considered related to startup.
	Later on, we ignore errors here, we assume the external process died out of our control."
	(self hasStarted not and: [ status isNil or: [ status isSuccess not ] ])
		ifTrue: [ self error: 'Unable to run pipenv ' , (Character space join: self processArguments) ].
]

{ #category : #private }
PBNewPharoPipenvProcess >> newExternalProcessBuilder [
	| builder |
	builder := GtExternalProcessBuilder new
			command: self pipenvPath fullName;
			workingDirectory: self workingDirectory;
			yourself.
	^ builder
]

{ #category : #private }
PBNewPharoPipenvProcess >> newPythonBridgeProcess [
	| builder command |
	builder := self newExternalProcessBuilder.
	builder args: self processArguments.
	command := builder createNativeCommand.
	self copyEnvVarsTo: command.
	builder
		pipeStdout;
		pipeStderr.
	process := command spawn.
	process terminateOnShutdown.
	monitorProcess := [ self monitorProcess ] forkNamed: 'PythonBridge monitor'
]

{ #category : #accessing }
PBNewPharoPipenvProcess >> pipenvPath [
	"Answer the to use pipenvPath.
	This may be overridden by the application settings."

	^ self settings pipenvPath ifNil: [ self class pipenvPath ]
]

{ #category : #private }
PBNewPharoPipenvProcess >> pollStdoutAndStderr [
	process ifNil: [ ^ self ].
	stdoutStream nextPutAll: process asynchronousStdout pollString.
	stderrStream nextPutAll: process asynchronousStderr pollString. 
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
	self newPythonBridgeProcess.
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
	^ stderrStream contents
]

{ #category : #accessing }
PBNewPharoPipenvProcess >> stdout [
	^ stdoutStream contents
]

{ #category : #'start-stop' }
PBNewPharoPipenvProcess >> stop [
	process ifNil: [ ^ self ].
	process terminateAll.
	process := nil
]

{ #category : #utilities }
PBNewPharoPipenvProcess >> uninstallModule: aModule in: aPBApplication [
	| builder  args description time output  |
	args := OrderedCollection with: 'uninstall'. 
	aModule ifNotNil: [ args add: aModule ].
	description := Character space join: #(pipenv) , args.
	time := Time millisecondClockValue.
	builder := self newExternalProcessBuilder.
	builder arguments: args.
	output := self waitForProcessAsync: builder.
	self assert: output status isSuccess.
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

{ #category : #private }
PBNewPharoPipenvProcess >> waitForProcessAsync: processBuilder [
	"Run the native process described in processBuilder and wait for it to complete and produce output.
	The output, an instance of GtNativeExternalProcessOutput, can be queried for its status, stdout and stderr.
	This wait will block the current process but not the VM"

	| nativeProcess |
	processBuilder 
		pipeStdout; 
		pipeStderr.
	nativeProcess := processBuilder spawn.
	^ nativeProcess waitAsyncWithOutput
]
