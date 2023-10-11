Class {
	#name : #PBExecutionHandler,
	#superclass : #LanguageLinkExecutionHandler,
	#category : #'PythonBridge-Execution'
}

{ #category : #initialization }
PBExecutionHandler >> initializeHandler [
	commandQueue := PBCommandQueue new.
	mapperFactory := LanguageLinkMapperFactory forExecutionHandler: self.
	promiseRegistry := LanguageLinkPromiseRegistry new.
	weakRegistry := PBPlatform current weakRegistry.
	objectRegistry := LanguageLinkObjectRegistry new.
	self communicationHandler
		addHandler: [ :msg | self notifyHandler: msg ] forMessageClass: LanguageLinkUpdatePromiseMessage;
		addHandler: [ :msg | self notifyErrorHandler: msg ] forMessageClass: LanguageLinkErrorMessage;
		addHandler: [ :msg | self notifyCallbackHandler: msg ] forMessageClass: LanguageLinkCallbackMessage
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

{ #category : #initialization }
PBExecutionHandler >> objectRegistry [
	^ objectRegistry
]

{ #category : #'private protocol' }
PBExecutionHandler >> primitiveSendCommand: command [
	^ self communicationHandler sendMessage: (self buildMessageFromCommand: command)
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
