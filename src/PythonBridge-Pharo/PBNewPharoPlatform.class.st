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
	^ 0
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
			anApplication workingDirectory ensureDirectory.
			anApplication installModule: 'gtoolkit_bridge'.
			anApplication installModule: 'debugpy' ]
]
