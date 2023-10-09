Class {
	#name : #PBStubApplication,
	#superclass : #PBApplication,
	#category : #'PythonBridge-Tests'
}

{ #category : #initialization }
PBStubApplication >> handlers [
	^ Array with: loggingHandler
]

{ #category : #initialization }
PBStubApplication >> initializeHandlers [
	loggingHandler := LanguageLinkLoggingHandler application: self.
]
