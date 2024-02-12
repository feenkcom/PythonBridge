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
		'process'
	],
	#category : #'PythonBridge-Pharo-Processes'
}

{ #category : #accessing }
PBNewPharoPipenvProcess class >> pipenvPath [
	^ PBPharoPipenvPathFinder pipenvPath
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
			{ 'working directory' . self workingDirectory }.
			{ 'virtual environment' . self installedVirtualEnvironment asFileReference }.
			{ 'server address' . self settings serverSocketAddress }.
			{ 'message format' . PBPlatform current messageBrokerStrategy methodArg }.
			{ 'debug mode' . self debugMode }
		} ];
		column: 'Key' text: #first weight: 0.5;
		column: 'Value' text: #second;
		send: #last
]

{ #category : #'gt extensions' }
PBNewPharoPipenvProcess >> gtViewInstalledModulesIn: composite [
	<gtView>
	^ composite columnedTree
		title: 'Modules';
		priority: 50;
		items: [ self installedModules ];
		children: [ :each | each at: #dependencies ];
		column: #name text: [ :each | each at: #package_name ];
		column: #version text: [ :each | each at: #installed_version ];
		expandAll
]

{ #category : #accessing }
PBNewPharoPipenvProcess >> hasProcess [
	^ process isNotNil
]

{ #category : #utilities }
PBNewPharoPipenvProcess >> installModule: aModule in: aPBApplication [
	| proc args |
	args := OrderedCollection with: 'install'. 
	aModule ifNotNil: [ args add: aModule ].
	proc := self newOneShotProcess.
	proc
		arguments: args;
		errorBlock: [ 
			self error: 'Unable to execute pipenv '
				, (Character space join: args)  ].
	proc runAndWait.
	self assert: proc isSuccess
]

{ #category : #utilities }
PBNewPharoPipenvProcess >> installedModules [
	| proc |
	proc := self newOneShotProcess.
	proc arguments: #( 'graph' '--json-tree' ).
	proc errorBlock: [ self error: 'pipenv graph failed' ].
	proc runAndWait.
	self assert: proc isSuccess.
	^ NeoJSONObject fromString: proc stdout
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
			process ifNotNil: [
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

{ #category : #private }
PBNewPharoPipenvProcess >> processArguments [
	| args |
	args := OrderedCollection with: 'run' with: 'python'.
	self settings serverDebugMode
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

{ #category : #'start-stop' }
PBNewPharoPipenvProcess >> start [
	process := self newProcess.
	process run
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
