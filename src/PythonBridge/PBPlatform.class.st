Class {
	#name : #PBPlatform,
	#superclass : #LanguageLinkPlatform,
	#instVars : [
		'processStrategy'
	],
	#classVars : [
		'Current'
	],
	#category : #'PythonBridge-Platform'
}

{ #category : #accessing }
PBPlatform class >> current [
	^ Current ifNil: [ Current := self getConcretePlatform new ]
]

{ #category : #accessing }
PBPlatform class >> current: aPlatform [
	Current := aPlatform
]

{ #category : #utils }
PBPlatform class >> getConcretePlatform [
	^ (self allSubclasses reject: #isAbstract) 
			inject: nil 
			into: [ :candidate :next |
							candidate 
								ifNil: [ next ]
								ifNotNil: [ 
									candidate priority > next priority
										ifTrue: [ candidate ]
										ifFalse: [ next ] ] ] 
]

{ #category : #hooks }
PBPlatform class >> globalPythonProcessClass [
	self subclassResponsibility
]

{ #category : #hooks }
PBPlatform class >> httpMessageBrokerClass [
	self subclassResponsibility
]

{ #category : #testing }
PBPlatform class >> isAbstract [
	^ self name = 'PBPlatform' asSymbol
]

{ #category : #hooks }
PBPlatform class >> manualProcessClass [
	self subclassResponsibility
]

{ #category : #hooks }
PBPlatform class >> pipenvProcessClass [
	self subclassResponsibility
]

{ #category : #accessing }
PBPlatform class >> platform [
	^ self current
]

{ #category : #private }
PBPlatform class >> priority [
	^ -547835385
]

{ #category : #accessing }
PBPlatform class >> reset [
	self current: nil
]

{ #category : #hooks }
PBPlatform class >> socketMessageBrokerClass [
	self subclassResponsibility
]

{ #category : #'message broker strategy' }
PBPlatform >> defaultMessageBrokerClass [
	^ self class httpMessageBrokerClass
]

{ #category : #utils }
PBPlatform >> defaultSettings [
	| basePortNumber |
	"Use 3 consecutive port numbers, makes it easier to listen using a port range in wireshark"
	basePortNumber := 7000 + 99 atRandom.
	^ PBSettings new
		clientSocketAddress: (LanguageLinkSocketAddress ipOrName: 'localhost' port: basePortNumber);
		serverSocketAddress: (LanguageLinkSocketAddress ipOrName: 'localhost' port: basePortNumber + 1);
		debugSocketAddress: (LanguageLinkSocketAddress ipOrName: 'localhost' port: basePortNumber + 2);
		messageBrokerStrategy: self messageBrokerStrategy;
		platform: PBPharoPlatform new;
		commandFactoryClass: PBCommandFactory;
		commandClass: PBCommand;
		serializerClass: LanguageLinkSerializer;
		deserializerClass: PBDeserializer;
		parserClass: PythonParser;
		connectionExceptionHandler: PharoLinkConnectionExceptionHandler new;
		workingDirectory: FileLocator imageDirectory / PBApplication runtimeDirectory
]

{ #category : #accessing }
PBPlatform >> folderForApplication [
	^ FileLocator imageDirectory / PBApplication runtimeDirectory
]

{ #category : #'gt-extensions' }
PBPlatform >> gtSettingsFor: aView [
	<gtView>

	^ aView forward 
		title: 'Settings';
		priority: 60;
		object: [ self defaultSettings ];
		view: #gtSettingsFor:
]

{ #category : #'module creation' }
PBPlatform >> messageBroker: settings [
	^ self messageBrokerStrategy settings: settings
]

{ #category : #'message broker strategy' }
PBPlatform >> messageBrokerStrategy [
	^ msgBrokerStrategy ifNil: [ ^ msgBrokerStrategy := self defaultMessageBrokerClass ]
]

{ #category : #'message broker strategy' }
PBPlatform >> messageBrokerStrategy: msgBrokerCls [
	msgBrokerStrategy := msgBrokerCls
]

{ #category : #accessing }
PBPlatform >> newRandomName [
	^ 'pb' , UUID new asString36
]

{ #category : #'module creation' }
PBPlatform >> process: application [
	^ self processStrategy application: application
]

{ #category : #'process strategy' }
PBPlatform >> processStrategy [
	^ processStrategy ifNil: [ ^ self class pipenvProcessClass ]
]

{ #category : #'process strategy' }
PBPlatform >> processStrategy: processCls [
	processStrategy := processCls
]

{ #category : #'message broker strategy' }
PBPlatform >> setHttpMessageBroker [
	self messageBrokerStrategy: self class httpMessageBrokerClass
]

{ #category : #'process strategy' }
PBPlatform >> setManualProcess [
	self processStrategy: self class manualProcessClass
]

{ #category : #'process strategy' }
PBPlatform >> setPipenvProcess [
	self processStrategy: self class pipenvProcessClass
]

{ #category : #'message broker strategy' }
PBPlatform >> setSocketMessageBroker [
	self messageBrokerStrategy: self class socketMessageBrokerClass
]
