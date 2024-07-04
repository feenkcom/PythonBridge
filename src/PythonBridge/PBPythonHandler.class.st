Class {
	#name : #PBPythonHandler,
	#superclass : #LanguageLinkHandler,
	#instVars : [
		'process'
	],
	#category : #'PythonBridge-Core'
}

{ #category : #'start-stop' }
PBPythonHandler >> applicationReady [
	process applicationReady
]

{ #category : #accessing }
PBPythonHandler >> errorMessage [
	^ process errorMessage
]

{ #category : #accessing }
PBPythonHandler >> exitCode [
	^ process exitCode
]

{ #category : #'gt extensions' }
PBPythonHandler >> gtDetails [
	^ super gtDetails , {
		{ #process . process }
	}
]

{ #category : #accessing }
PBPythonHandler >> gtPackage [
	^ process gtPackage
]

{ #category : #'gt extensions' }
PBPythonHandler >> gtViewInstalledModulesIn: composite [
	<gtView>
	^ composite forward
		title: 'Modules';
		priority: 30;
		object: [ process ];
		view: #gtViewInstalledModulesIn:
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

{ #category : #accessing }
PBPythonHandler >> pythonBridgePackage [
	^ process pythonBridgePackage
]

{ #category : #'start-stop' }
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

{ #category : #'start-stop' }
PBPythonHandler >> stop [
	^ process stop
]

{ #category : #utilities }
PBPythonHandler >> uninstallModule: aModule [
	"Uninstall the supplied module aModule"

	process uninstallModule: aModule in: application
]
