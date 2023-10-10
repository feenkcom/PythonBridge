Class {
	#name : #PBPromise,
	#superclass : #LanguageLinkPromise,
	#category : #'PythonBridge-Execution'
}

{ #category : #accessing }
PBPromise >> exception [
	"Answer the receiver's exception"

	(value isKindOf: Exception) ifFalse:
		[ self error: 'Promise isn''t broken' ].
	^ value
]

{ #category : #signalling }
PBPromise >> waitForValue [
	"Wait for the server to supply the result and answer it.
	If the value is an exception, the issue may be resolved and the promise flagged to wait for the new value to come through (waitAgain)."
	<remoteDebuggerSignal>

	[ waitAgain := false.
	self isSignaled ifFalse: [ semaphore wait ].
	(value isKindOf: Exception) ifTrue:
		[ value promise: self.
		value signal ].
	"If an exception was signalled, it may request that the promise wait for the real value to come through."
	waitAgain ] whileTrue.
	^ value
]
