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
	promiseRegistry := LanguageLinkPromiseRegistry new.
	weakRegistry := PBPlatform current weakRegistry.
	objectRegistry := LanguageLinkObjectRegistry new
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
	error := PharoLinkRemoteError new
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

{ #category : #accessing }
PBExecutionHandler >> registerObject: aPythonObject [
	objectRegistry registerObject: aPythonObject.
	weakRegistry 
		registerObject: aPythonObject 
		finalizer: (LanguageLinkRegistryFinalizer 
							variable: aPythonObject pythonVariable 
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

{ #category : #accessing }
PBExecutionHandler >> registryExpression [
	^ #registry callWith: #()
]

{ #category : #accessing }
PBExecutionHandler >> removeId: aRemoteProxyId [
	^ self registryExpression => #clean callWith: (Array with: aRemoteProxyId)
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
