Class {
	#name : #PBRemoteNotification,
	#superclass : #Notification,
	#instVars : [
		'promise'
	],
	#category : #'PythonBridge-ErrorHandling'
}

{ #category : #testing }
PBRemoteNotification >> isPaused [
	"Answer a boolean indicating whether the receiver represents an exception that can be debugged / continued.
	Only PBDebuggerPaused can be continued"

	^ false

]

{ #category : #accessing }
PBRemoteNotification >> promise [
	^ promise
]

{ #category : #accessing }
PBRemoteNotification >> promise: anObject [
	promise := anObject
]
