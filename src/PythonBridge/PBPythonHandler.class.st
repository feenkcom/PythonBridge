Class {
	#name : #PBPythonHandler,
	#superclass : #LanguageLinkHandler,
	#instVars : [
		'process'
	],
	#category : #'PythonBridge-Core'
}

{ #category : #accessing }
PBPythonHandler >> errorMessage [
	^ process errorMessage
]

{ #category : #accessing }
PBPythonHandler >> exitCode [
	^ process exitCode
]

{ #category : #accessing }
PBPythonHandler >> gtPackage [
	^ process gtPackage
]

{ #category : #testing }
PBPythonHandler >> hasProcess [

	^ process hasProcess
]

{ #category : #initialization }
PBPythonHandler >> initializeHandler [
	super initializeHandler.
	process := PBPlatform current process: self application
]

{ #category : #utilities }
PBPythonHandler >> installModule: aModule [
	"Install the supplied module aModule"

	process installModule: aModule in: application
]

{ #category : #testing }
PBPythonHandler >> isRunning [
	^ process isRunning
]

{ #category : #accessing }
PBPythonHandler >> pipenvPath [ 
	"Answer the default pipenvPath.
	This may be overridden by the application settings."

	^ process pipenvPath
]

{ #category : #accessing }
PBPythonHandler >> platform [
	^ PBPlatform current
]

{ #category : #testing }
PBPythonHandler >> start [
	self platform ensureEnvironmentForApp: self application.
	^ process start
]

{ #category : #accessing }
PBPythonHandler >> stderr [
	"Answer the process stderr contents"

	^ process stderr
]

{ #category : #accessing }
PBPythonHandler >> stdout [ 
	"Answer the process stdout contents"

	^ process stdout
]

{ #category : #testing }
PBPythonHandler >> stop [
	^ process stop
]
