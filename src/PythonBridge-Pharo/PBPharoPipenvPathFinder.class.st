Class {
	#name : #PBPharoPipenvPathFinder,
	#superclass : #Object,
	#classVars : [
		'PipenvPath'
	],
	#category : #'PythonBridge-Pharo-Processes'
}

{ #category : #accessing }
PBPharoPipenvPathFinder class >> pipenvPath [
	^ PipenvPath
		ifNil: [ PipenvPath := self resolvePipenvPath ]
		ifNotNil: [ PipenvPath ]
]

{ #category : #accessing }
PBPharoPipenvPathFinder class >> pipenvPath: aFileReference [
	PipenvPath := aFileReference
]

{ #category : #utilities }
PBPharoPipenvPathFinder class >> resolvePipenvPath [
	| path process |
	process := GtSubprocessWithInMemoryOutput new
			command: (Smalltalk os isWindows ifTrue: [ 'where' ] ifFalse: [ 'which' ]);
			arguments: #('pipenv').
	Smalltalk os isWindows
		ifFalse: [ | originalPath extraPath extendedPath |
			originalPath := $: split: (Smalltalk os environment at: 'PATH').
			"Search in some extra places that might not be in PATH"
			extraPath := #('/usr/local/bin').
			extendedPath := $: join: extraPath , originalPath.
			process environmentAt: 'PATH' put: extendedPath ].
	process
		addAllEnvVariablesFromParentWithoutOverride;
		terminateOnShutdown;
		runAndWait.
	(#(0 1) includes: process exitCode)
		ifFalse: [ self signalPipenvNotFound ].
	path := process stdout trimBoth.
	Smalltalk os isWindows
		ifTrue: [ path := (path lines
					select: [ :aString | 
						"We want to remove HOME\.pyenv\pyenv-win\shims\pipenv,
						because it is a BASH script that is supposed to be executed
						in cygwin or in git-bash."
						#(bat exe) includes: aString asFileReference extension asLowercase ])
					ifEmpty: [ self signalPipenvNotFound ]
					ifNotEmpty: [ :anArray | anArray first trimBoth ] ].
	path ifEmpty: [ self signalPipenvNotFound ].
	^ path asFileReference
]

{ #category : #privavte }
PBPharoPipenvPathFinder class >> signalPipenvNotFound [
	"
	PythonBridge use the unix command `which` or the windows command `where`
	to find the full path of the `pipenv` command. 
	From Pharo we could not find the route, therefore you have to set it mannualy.
		
	To find the path of Pipenv in your system run the command `which pipenv`
	or `where pipenv` in the terminal.
	
	The pipenv executable must be reachable from your system's PATH for this to work.
	
	To set the path in PythonBridge send the following message:
	
	PBPharoPipenvPathFinder pipenvPath: '/usr/local/bin/pipenv' asFileReference
	
	or set it in your PBApplication's PBSettings:
	
	myPBApplication settings pipenvPath: '/usr/local/bin/pipenv' asFileReference
	"
	
	Error signal: 'pipenv command could not be found'
]
