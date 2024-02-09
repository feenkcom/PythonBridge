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
	^ PBPharoPipenvProcess pipenvPath
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

{ #category : #accessing }
PBNewPharoPipenvProcess >> hasProcess [
	^ process isNotNil
]

{ #category : #utilities }
PBNewPharoPipenvProcess >> installModule: aModule in: aPBApplication [
	| proc args |
	args := OrderedCollection with: 'install'. 
	aModule ifNotNil: [ args add: aModule ].
	proc := self newBaseProcess.
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
	proc := self newBaseProcess.
	proc arguments: #( 'graph' ).
	proc errorBlock: [ self error: 'pipenv graph failed' ].
	proc runAndWait.
	self assert: proc isSuccess.
	^ proc stdout
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
			terminateOnShutdown;
			yourself.
	^ newProcess
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
		add: PBPlatform current messageBrokerStrategy methodArg.
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
	process terminate.
	process := nil
]
