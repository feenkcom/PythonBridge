Class {
	#name : #PBPharoPipenvPathFinder,
	#superclass : #Object,
	#classVars : [
		'PipenvPath'
	],
	#category : #'PythonBridge-Pharo-Processes'
}

{ #category : #accessing }
PBPharoPipenvPathFinder class >> extraPathNonWindows [
	"Search in some extra places that might not be in PATH by default"
				
	^ #('/usr/local/bin' '/opt/homebrew/bin' '/opt/local/bin')
]

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

{ #category : #utilites }
PBPharoPipenvPathFinder class >> reset [
	self pipenvPath: nil
]

{ #category : #utilities }
PBPharoPipenvPathFinder class >> resolvePipenvPath [
	| builder output path |
	builder := GtExternalProcessBuilder new
			command: (Smalltalk os isWindows ifTrue: [ 'where' ] ifFalse: [ 'which' ]);
			arg: 'pipenv'.
	Smalltalk os isWindows
		ifFalse: [ | originalPath extendedPath |
			originalPath := $: split: (Smalltalk os environment at: 'PATH').
			extendedPath := $: join: self extraPathNonWindows , originalPath.
			builder env: 'PATH' value: extendedPath ].
	output := builder output.
	output status isSuccess
		ifFalse: [ ^ self signalPipenvNotFound ].
	path := output stdout trimBoth.
	Smalltalk os isWindows
		ifTrue: [ | lines | 
			lines := path lines
					collect: [ :line | line trimBoth asFileReference ]
					thenSelect: [ :each | #(bat exe) includes: each extension asLowercase ].
			path := lines
				ifEmpty: [ ^ self signalPipenvNotFound ]
				ifNotEmpty: [ :anArray | anArray first trimBoth ] ].
	path ifEmpty: [ ^ self signalPipenvNotFound ].
	^ path asFileReference
]

{ #category : #privavte }
PBPharoPipenvPathFinder class >> signalPipenvNotFound [
	"PythonBridge use the unix command `which` or the windows command `where`
	to find the full path of the `pipenv` command. 
	From Pharo we could not find the route, therefore you have to set it mannualy.
		
	To find the path of Pipenv in your system run the command `which pipenv`
	or `where pipenv` in the terminal.
	
	The pipenv executable must be reachable from your system's PATH for this to work.
	
	To set the path in PythonBridge send the following message:
	
	PBPharoPipenvPathFinder pipenvPath: '/usr/local/bin/pipenv' asFileReference
	
	or set it in your PBApplication's PBSettings:
	
	myPBApplication settings pipenvPath: '/usr/local/bin/pipenv' asFileReference"
	
	Error signal: 'pipenv command could not be found'
]
