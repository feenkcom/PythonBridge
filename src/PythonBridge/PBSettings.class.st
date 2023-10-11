Class {
	#name : #PBSettings,
	#superclass : #LanguageLinkSettings,
	#instVars : [
		'pharoSocketAddress',
		'pythonSocketAddress',
		'pipenvPath',
		'debugSocketAddress'
	],
	#category : #'PythonBridge-Platform'
}

{ #category : #accessing }
PBSettings class >> pharoSocketAddress: pharoSocketAddress pythonSocketAddress: pythonSocketAddress [
	^ self new
		clientSocketAddress: pharoSocketAddress;
		serverSocketAddress: pythonSocketAddress;
		yourself
]

{ #category : #accessing }
PBSettings >> debugSocketAddress [
	^ debugSocketAddress
]

{ #category : #accessing }
PBSettings >> debugSocketAddress: anObject [
	debugSocketAddress := anObject
]

{ #category : #accessing }
PBSettings >> pipenvPath [
	^ pipenvPath
]

{ #category : #accessing }
PBSettings >> pipenvPath: aFileReference [

	pipenvPath := aFileReference asFileReference.
	pipenvPath ifNil: [ ^ self ].
	self assert: [ pipenvPath exists ]
		description: pipenvPath fullName, ' doesn''t exist'.
]
