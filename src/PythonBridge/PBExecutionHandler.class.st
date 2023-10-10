Class {
	#name : #PBExecutionHandler,
	#superclass : #LanguageLinkExecutionHandler,
	#category : #'PythonBridge-Execution'
}

{ #category : #initialization }
PBExecutionHandler >> initialize [
	super initialize.
	commandQueue := PBCommandQueue new.
	mapperFactory := PBMapperFactory forExecutionHandler: self.
	promiseRegistry := PBPromiseRegistry new.
	weakRegistry := PBPlatform current weakRegistry.
	objectRegistry := PBObjectRegistry new
]

{ #category : #initialization }
PBExecutionHandler >> initializeHandler [
	self communicationHandler
		addHandler: [ :msg | self notifyHandler: msg ] forMessageClass: PBUpdatePromiseMessage;
		addHandler: [ :msg | self notifyErrorHandler: msg ] forMessageClass: PBErrorMessage;
		addHandler: [ :msg | self notifyCallbackHandler: msg ] forMessageClass: PBCallbackMessage
]

{ #category : #'as yet unclassified' }
PBExecutionHandler >> newCommandFactory [
	^ PBCommandFactory new
		application: self application;
		yourself
]

{ #category : #'as yet unclassified' }
PBExecutionHandler >> newCommandStringFactory [
	^ PBCommandStringFactory new
		application: self application;
		yourself
]

{ #category : #handlers }
PBExecutionHandler >> notifyErrorHandler: errorMsg [
	| error |
	error := PBPythonError new
					application: self application;
					command: (commandQueue getCommand: errorMsg commandId);
					errorMessage: errorMsg errorMessage;
					trace: errorMsg trace;
					yourself.
	self safeTriggerDebugger: error.
	^ errorMsg createAnswer 
			handlingAction: error proceedAction;
			yourself
]

{ #category : #handlers }
PBExecutionHandler >> notifyHandler: updatePromiseMsg [
	self 
		updatePromiseId: updatePromiseMsg promiseId 
		with: (self deserialize: updatePromiseMsg value)
]

{ #category : #initialization }
PBExecutionHandler >> objectRegistry [
	^ objectRegistry
]

{ #category : #'private protocol' }
PBExecutionHandler >> primitiveSendCommand: command [
	^ self communicationHandler sendMessage: (self buildMessageFromCommand: command)
]

{ #category : #'as yet unclassified' }
PBExecutionHandler >> registerObject: aPythonObject [
	objectRegistry registerObject: aPythonObject.
	weakRegistry 
		registerObject: aPythonObject 
		finalizer: (PBRegistryFinalizer 
							pythonVariable: aPythonObject pythonVariable 
							executionHandler: self)
]

{ #category : #'private protocol' }
PBExecutionHandler >> registerPromiseForCommand: aCommand [
	| promise |
	promise := PBPromise new
					id: aCommand id;
					transformBlock: aCommand transformBlock;
					yourself.
	aCommand promise: promise.
	promiseRegistry addPromise: promise.
	^ promise
]

{ #category : #'as yet unclassified' }
PBExecutionHandler >> safeTriggerDebugger: error [

	[ promiseRegistry signalPromiseId: error command id with: error ] fork.

]

{ #category : #'private protocol' }
PBExecutionHandler >> sendCommand: command [
	| promise |
	self assert: command isValid.
	commandQueue enqueueCommand: command.
	promise := self registerPromiseForCommand: command.
	self primitiveSendCommand: command.
	^ promise
]

{ #category : #'private protocol' }
PBExecutionHandler >> serialize: anObject [
	^ mapperFactory serializer serialize: anObject
]

{ #category : #'private protocol' }
PBExecutionHandler >> signalObserver: observer withValue: object [
	^ observer pharoNotify: object
]

{ #category : #accessing }
PBExecutionHandler >> stop [
	super stop.
	weakRegistry destroy
]

{ #category : #'as yet unclassified' }
PBExecutionHandler >> triggerDebugger: pythonError [
	"This method is called when an error rised on Python execution."
	"Inspect error to review the Command that caused the error.
	For ignoring error:
		pythonError proceedAction: PBIgnore new
	For aborting:
		pythonError proceedAction: PBDropQueue new
	For replacing the command that caused the error:
		pythonError proceedAction: P3ReplaceCommandAction new newCommand: **Your crafted command**
	To execute your action you just need to 'Proceed' in the debugger."
	pythonError signal.
]

{ #category : #'private protocol' }
PBExecutionHandler >> updatePromiseId: id with: anObject [
	commandQueue finishCommandId: id.
	promiseRegistry removeAndSignalPromiseId: id with: anObject
]
