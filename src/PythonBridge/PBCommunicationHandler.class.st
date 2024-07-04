Class {
	#name : #PBCommunicationHandler,
	#superclass : #LanguageLinkCommunicationHandler,
	#category : #'PythonBridge-Core'
}

{ #category : #'gt extensions' }
PBCommunicationHandler >> gtDetails [
	^ super gtDetails , {
		{ #messageBroker . messageBroker }
	}
]

{ #category : #initialization }
PBCommunicationHandler >> initializeHandler [
	messageBroker := PBPlatform current messageBroker: self application settings
]
