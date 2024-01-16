"
Experimental implementation of a simpler, direct Python Bridge process.

To enable
```
PBPlatform current processStrategy: PBPharoDirectPythonProcess
```

Now create a new bridge as usual and start it.

To disable
```
PBPlatform reset
```



"
Class {
	#name : #PBPharoDirectPythonProcess,
	#superclass : #LanguageLinkAbstractProcess,
	#instVars : [
		'process'
	],
	#category : #'PythonBridge-Pharo-Processes'
}

{ #category : #accessing }
PBPharoDirectPythonProcess >> errorMessage [
	^ self stderr
]

{ #category : #accessing }
PBPharoDirectPythonProcess >> exitCode [
	^ process exitCode
]

{ #category : #testing }
PBPharoDirectPythonProcess >> hasProcess [
	^ process isNotNil
]

{ #category : #testing }
PBPharoDirectPythonProcess >> isRunning [
	^ process notNil and: [ process isRunning ]
]

{ #category : #private }
PBPharoDirectPythonProcess >> newProcess [
	^ GtSubprocessWithInMemoryOutput new
		workingDirectory: self workingDirectory fullName;
		command: self pythonCommand;
		arguments: self processArguments;
		yourself
]

{ #category : #private }
PBPharoDirectPythonProcess >> processArguments [
	| arguments |
	arguments := OrderedCollection new .
	arguments
		add: self pythonMainFile;
		add: '--port';
		add: self settings serverSocketAddress port asString;
		add: '--pharo';
		add: 0 asString; "this does not seem to be used"
		add: '--method';
		add: PBPlatform current messageBrokerStrategy methodArg.
	self debugMode ifTrue: [ arguments add: '--log' ].
	^ arguments
]

{ #category : #private }
PBPharoDirectPythonProcess >> pythonCommand [
	^ Smalltalk os isMacOS
		ifTrue: [ 'python3' ]
		ifFalse: [ 'python' ]
]

{ #category : #private }
PBPharoDirectPythonProcess >> pythonMainFile [
	^ 'start_bridge.py'
]

{ #category : #'start-stop' }
PBPharoDirectPythonProcess >> start [
	process := self newProcess.
	process run
]

{ #category : #accessing }
PBPharoDirectPythonProcess >> stderr [
	^ process stderr
]

{ #category : #accessing }
PBPharoDirectPythonProcess >> stdout [
	^ process stdout 
]

{ #category : #'start-stop' }
PBPharoDirectPythonProcess >> stop [
	process ifNil: [ ^ self ].
	process terminate
]
