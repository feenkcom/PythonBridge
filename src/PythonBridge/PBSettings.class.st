Class {
	#name : #PBSettings,
	#superclass : #LanguageLinkSettings,
	#instVars : [
		'pipenvPath',
		'debugSocketAddress'
	],
	#category : #'PythonBridge-Platform'
}

{ #category : #accessing }
PBSettings class >> pharoSocketAddress: pharoSocketAddress pythonSocketAddress: pythonSocketAddress [
	^ self new
		clientSocketAddress: pharoSocketAddress;
		serverSocketAddress: pythonSocketAddress;
		yourself
]

{ #category : #accessing }
PBSettings >> debugSocketAddress [
	^ debugSocketAddress
]

{ #category : #accessing }
PBSettings >> debugSocketAddress: anObject [
	debugSocketAddress := anObject
]

{ #category : #utils }
PBSettings >> deleteRuntimeEnvironment [
	"Delete the whole PythonBridgeRuntime working directory.
	This will effectively force reinstallation on the next run.
	Only execute when you have not added or editing anything there"
	
	self workingDirectory deleteAll
]

{ #category : #ui }
PBSettings >> gtDeleteActionFor: anAction [
	<gtAction>
	^ anAction button
		icon: BrGlamorousVectorIcons remove;
		tooltip: 'Delete the runtime environment';
		priority: 20;
		action: [ :element | self deleteRuntimeEnvironment ]
]

{ #category : #accessing }
PBSettings >> manualCommand [
	^ 'pipenv run python -m gtoolkit_bridge --port {1} --pharo {2} --method {3}{4}' 
		format: { 
			self serverSocketAddress port . 
			self clientSocketAddress port .
			self messageBrokerStrategy methodArg.
			self debugMode ifTrue: [ ' --log' ] ifFalse: [ '' ] }
]

{ #category : #accessing }
PBSettings >> pipenvPath [
	^ pipenvPath
]

{ #category : #accessing }
PBSettings >> pipenvPath: aFileReference [

	pipenvPath := aFileReference asFileReference.
	pipenvPath ifNil: [ ^ self ].
	self assert: [ pipenvPath exists ]
		description: pipenvPath fullName, ' doesn''t exist'.
]
