Class {
	#name : #PBMethodObject,
	#superclass : #PBProxyObject,
	#category : #'PythonBridge-Core'
}

{ #category : #accessing }
PBMethodObject class >> pythonClass [
	^'method'
]

{ #category : #ui }
PBMethodObject >> asBrMenuWithSelfObjectHolder: aSelfObjectHolder [
	^ BrMenuExplicit new
		stencil: [ :aMenuModel | 
			| aCoderElement |
			aCoderElement := (self gtSourceFor: GtPhlowView empty)
				asElementDo: [ :e | e ].
			aCoderElement
				hExact: 500;
				vFitContentLimited;
				background: aCoderElement theme default contentBackgroundColor;
				addAptitude: (BrGlamorousMenuPinnableAptitude new
						menuModel: aMenuModel;
						withResizers;
						withAllPinActions);
				addAptitude: (BrMenuHideableAptitude new menuModel: aMenuModel);
				addAptitude: BrMenuCommonAptitude new ]
]

{ #category : #accessing }
PBMethodObject >> file [
	| filename model |
	filename := (self newCommandFactory
			<< ('inspect.getfile' asP3GIdentifier callWith: {self});
			sendAndWait) asFileReference.
	model := GtLSPPythonModel onDirectory: filename parent.
	^ GtLSPFileModel new
		filename: filename;
		directory: model;
		yourself
]

{ #category : #ui }
PBMethodObject >> gtPhlowIncludesCompiledMethod: aCompiledMethod [ 
	^ false
]

{ #category : #accessing }
PBMethodObject >> gtSourceFor: aView [
	<gtView>
	| sl | 
	[ sl := self sourceLines ] on: Exception do: [ ^ aView empty ].
	^ aView forward
		title: 'Source';
		priority: 2;
		object: [ 
			GtLSPFileLocation new
				lspFile: self file;
				startPosition: (GtLSPPositionStructure new
						line: sl second - 1;
						character: 0;
						yourself);
				endPosition: (GtLSPPositionStructure new
						line: sl second + sl first size - 2;
						character: sl first last size - 1;
						yourself) ];
		view: #gtLiveFor:
]

{ #category : #accessing }
PBMethodObject >> source [
	^ self newCommandFactory
		<< ('inspect.getsource' asP3GIdentifier callWith: {self});
		sendAndWait
]

{ #category : #accessing }
PBMethodObject >> sourceLines [
	^ self newCommandFactory
		<< ('inspect.getsourcelines' asP3GIdentifier callWith: {self});
		sendAndWait
]
