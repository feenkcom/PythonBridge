"
I am PBPharoPipenvPathFinder, a cross platform tool to discover and manage the path to the pipenv executable.

```
PBPharoPipenvPathFinder pipenvPath
```

The path is cached. When it is not set, a discovery process runs to search in the system's PATH and a bunch of extra locations.

```
PBPharoPipenvPathFinder resolvePipenvPath
```

You can specify the explicitly if necessary, when it cannot be found.

```
PBPharoPipenvPathFinder pipenvPath: '/usr/local/bin/pipenv'
```


"
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

{ #category : #utilites }
PBPharoPipenvPathFinder class >> reset [
	self pipenvPath: nil
]

{ #category : #utilities }
PBPharoPipenvPathFinder class >> resolvePipenvPath [
	^ [ GtOsSystemInfo current findExecutable: 'pipenv' ]
		on: Error
		do:[ self signalPipenvNotFound ]
]

{ #category : #privavte }
PBPharoPipenvPathFinder class >> signalPipenvNotFound [
	"PythonBridge use the unix command `which` or the windows command `where`
	to find the full path of the `pipenv` command. 

	We could not find the route, therefore you have to set it mannualy.
		
	To find the path of Pipenv in your system run the command `which pipenv`
	or `where pipenv` in the terminal.
	
	The pipenv executable must be reachable from your system's PATH for this to work.
	
	To set the path in PythonBridge send the following message:
	
	PBPharoPipenvPathFinder pipenvPath: '/usr/local/bin/pipenv' asFileReference
	
	or set it in your PBApplication's PBSettings:
	
	myPBApplication settings pipenvPath: '/usr/local/bin/pipenv' asFileReference"
	
	Error signal: 'pipenv command could not be found'
]
