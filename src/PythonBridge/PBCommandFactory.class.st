Class {
	#name : #PBCommandFactory,
	#superclass : #LanguageLinkCommandFactory,
	#category : #'PythonBridge-Execution'
}

{ #category : #bindings }
PBCommandFactory >> addBinding: aBinding [
	bindingsDictionary at: aBinding pythonVariable name put: aBinding object.
	^ aBinding
]

{ #category : #bindings }
PBCommandFactory >> bindingAt: varName put: anObject [
	bindingsDictionary at: varName put: anObject.
	^ PBBinding key: varName wrap: anObject
]

{ #category : #bindings }
PBCommandFactory >> bindingWrap: anObject [
	^ self addBinding: (PBBinding wrap: anObject)
]

{ #category : #accessing }
PBCommandFactory >> decorateTransform: aBlock [
	| previousBlock |
	previousBlock := transformBlock.
	^ transformBlock := [ :obj | aBlock value: (previousBlock value: obj) ]
]

{ #category : #initialization }
PBCommandFactory >> initialize [
	super initialize.
	self reset
]

{ #category : #observers }
PBCommandFactory >> linkObserverClass [
	^ PBObserver
]

{ #category : #initialization }
PBCommandFactory >> reset [
	instructions := OrderedCollection new.
	bindingsDictionary := Dictionary new.
	observers := OrderedCollection new.
	command := PBCommand new.
	transformBlock := #yourself
]

{ #category : #initialization }
PBCommandFactory >> setNotifyToInstruction: aP3gInstruction [
	^ 'notify' asP3GIdentifier 
			callWith: (Array with: aP3gInstruction with: command id)
]
