"
I am PBNewPharoPlatform.
I am a PBPlatform.

I support the new approach that relies on the gtoolkit_bridge PyPI package.

See PBNewPharoPipenvProcess.
"
Class {
	#name : #PBNewPharoPlatform,
	#superclass : #PBPlatform,
	#category : #'PythonBridge-Pharo-Platform'
}

{ #category : #hooks }
PBNewPharoPlatform class >> httpMessageBrokerClass [
	^ LanguageLinkHttpMessageBroker
]

{ #category : #hooks }
PBNewPharoPlatform class >> manualProcessClass [
	^ LanguageLinkManualProcess
]

{ #category : #hooks }
PBNewPharoPlatform class >> pipenvProcessClass [
	^ PBNewPharoPipenvProcess
]

{ #category : #accessing }
PBNewPharoPlatform class >> priority [
	^ 20
]

{ #category : #hooks }
PBNewPharoPlatform class >> socketMessageBrokerClass [
	^ LanguageLinkMsgPackPharoBroker
]

{ #category : #hooks }
PBNewPharoPlatform class >> uiManagerClass [
	^ PBPharoUiManager
]

{ #category : #hooks }
PBNewPharoPlatform class >> weakRegistryClass [
	^ LanguageLinkPharoWeakRegistry
]

{ #category : #'message broker strategy' }
PBNewPharoPlatform >> defaultMessageBrokerClass [
	^ self class socketMessageBrokerClass
]

{ #category : #hooks }
PBNewPharoPlatform >> ensureEnvironmentForApp: anApplication [
	anApplication workingDirectory exists
		ifFalse: [
			[
				anApplication workingDirectory createDirectory.
				"Ask our application to install a number of Python modules inside our isolated pipenv environment"
				"The special nil module creates the pipenv virtual environment itself"
				#(nil 'gtoolkit_bridge' 'debugpy')
					do: [ :each | anApplication installModule: each ] 
			] asJob
				title: 'Installing PythonBridge runtime environment';
				run ]
]
