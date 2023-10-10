Class {
	#name : #PBCommunicationHandler,
	#superclass : #LanguageLinkCommunicationHandler,
	#category : #'PythonBridge-Core'
}

{ #category : #initialization }
PBCommunicationHandler >> initializeHandler [
	messageBroker := PBPlatform current messageBroker: self application settings
]

{ #category : #testing }
PBCommunicationHandler >> isServerReady [
	| semaphore ans |
	semaphore := Semaphore new.
	[ ans := [self sendMessage: PBIsAliveMessage new.
				true ] 
					on: LanguageLinkCommunicationError, PrimitiveFailed
					do: [ :e | false ].
	semaphore signal ] forkAt: Processor lowIOPriority.
	semaphore waitTimeoutMSecs: 100.
	^ ans notNil and: ans
]
