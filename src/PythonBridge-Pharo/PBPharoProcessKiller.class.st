"
I am PBPharoProcessKiller.

I work with a PBApplication to kill unwanted external processes that might be left running.

I do this by finding all process IDs whose command line matches a certain pattern.

If I find any, I kill them.

I was written because pipenv on Windows starts 3 processes on each invocation, while only one got killed the normal way.

I can run afterwards to do additional cleanup.

I do nothing when I am not running on Windows.
"
Class {
	#name : #PBPharoProcessKiller,
	#superclass : #Object,
	#instVars : [
		'application'
	],
	#category : #'PythonBridge-Pharo-Processes'
}

{ #category : #accessing }
PBPharoProcessKiller >> application [
	^ application
]

{ #category : #accessing }
PBPharoProcessKiller >> application: pbApplication [
	application := pbApplication
]

{ #category : #accessing }
PBPharoProcessKiller >> batFile [
	^ self workingDirectory / self scriptBasename , 'bat'
]

{ #category : #accessing }
PBPharoProcessKiller >> batFileContents [
	^ String crlf join: { 
		'@echo off'.
		'powershell -F {1} %1' format: { self ps1File pathString } }
]

{ #category : #running }
PBPharoProcessKiller >> ensureScripts [
	self batFile exists
		ifFalse: [ self batFile writeStreamDo: [ :out | out nextPutAll: self batFileContents ] ].
	self ps1File exists
		ifFalse: [ self ps1File writeStreamDo: [ :out | out nextPutAll: self ps1FileContents ] ]
]

{ #category : #running }
PBPharoProcessKiller >> getProcessIDs [
	| subProcess |
	subProcess := GtSubprocessWithInMemoryOutput new
		command: self batFile pathString;
		arguments: { self pattern };
		runAndWait;
		yourself.
	^ (subProcess stdout lines reject: #isEmpty) collect: [ :line |
		($: split: line) last ]
]

{ #category : #running }
PBPharoProcessKiller >> killProcessIDs: processIDs [
	GtSubprocessWithInMemoryOutput new
		command: 'taskkill';
		arguments: {'/F'} , (processIDs flatCollect: [ :each | { '/pid' . each } ]);
		runAndWait
]

{ #category : #accessing }
PBPharoProcessKiller >> pattern [
	| mainFile serverAddress clientAddress |
	mainFile := (self application processHandler instVarNamed: #process) pythonMainFile.
	serverAddress := self application settings serverSocketAddress.
	clientAddress := self application settings clientSocketAddress.
	^ 'name LIKE ''%python%'' AND commandline LIKE ''%{1} --port {2} --pharo {3}%''' format: {
		mainFile filename.
		serverAddress port.
		clientAddress port }
]

{ #category : #accessing }
PBPharoProcessKiller >> ps1File [
	^ self workingDirectory / self scriptBasename , 'ps1'
]

{ #category : #accessing }
PBPharoProcessKiller >> ps1FileContents [
	^ 'Get-CimInstance Win32_Process -Filter $args[0] | Select ProcessId | Format-List'
]

{ #category : #running }
PBPharoProcessKiller >> run [
	| processIDs |
	Smalltalk os isWindows ifFalse: [ ^ self ].
	self ensureScripts.
	processIDs := self getProcessIDs.
	self killProcessIDs: processIDs.
	^ processIDs
]

{ #category : #accessing }
PBPharoProcessKiller >> scriptBasename [
	^ 'find_tasks'
]

{ #category : #accessing }
PBPharoProcessKiller >> workingDirectory [
	^ self application settings workingDirectory
]
