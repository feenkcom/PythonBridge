Class {
	#name : #PBCommunicationHandler,
	#superclass : #LanguageLinkCommunicationHandler,
	#category : #'PythonBridge-Core'
}

{ #category : #initialization }
PBCommunicationHandler >> initializeHandler [
	messageBroker := PBPlatform current messageBroker: self application settings
]
