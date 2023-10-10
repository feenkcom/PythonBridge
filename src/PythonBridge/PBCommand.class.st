Class {
	#name : #PBCommand,
	#superclass : #LanguageLinkCommand,
	#category : #'PythonBridge-Execution'
}

{ #category : #accessing }
PBCommand >> codeForRemote [
	| py3CodeStream |
	py3CodeStream := String new writeStream.
	self instructions do: [ :instr | 
			instr writePython3On: py3CodeStream.
			py3CodeStream << String lf ].
	^ py3CodeStream contents
]

{ #category : #initialization }
PBCommand >> initialize [
	super initialize.
	id := PBPlatform current newRandomName.
	bindings := Dictionary new.
	observers := #().
	instructions := OrderedCollection new.
	transformBlock := #yourself
]
