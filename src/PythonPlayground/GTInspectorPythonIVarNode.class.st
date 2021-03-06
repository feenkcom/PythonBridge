Class {
	#name : #GTInspectorPythonIVarNode,
	#superclass : #GTInspectorVariableNode,
	#instVars : [
		'name',
		'pythonObject'
	],
	#category : #PythonPlayground
}

{ #category : #'as yet unclassified' }
GTInspectorPythonIVarNode class >> hostObject: host name: varName pythonObject: pyObject [
	^ (self hostObject: host)
			name: varName;
			pythonObject: pyObject;
			yourself
]

{ #category : #composition }
GTInspectorPythonIVarNode >> childrenNodesFor: aVariablesBrowser [
	"Return a collection of subvariable nodes to be displayed in a given raw variables browser.
	Note: by default we dispatch to browser and let it perform collection"
	<return: #Collection of: #GTInspectorVariableNode>
	^ aVariablesBrowser childrenVariableNodesForNode: self
]

{ #category : #accessing }
GTInspectorPythonIVarNode >> key [
	^ name asString
]

{ #category : #accessing }
GTInspectorPythonIVarNode >> name [
	^ name
]

{ #category : #accessing }
GTInspectorPythonIVarNode >> name: anObject [
	name := anObject
]

{ #category : #accessing }
GTInspectorPythonIVarNode >> pythonObject [
	^ pythonObject
]

{ #category : #accessing }
GTInspectorPythonIVarNode >> pythonObject: anObject [
	pythonObject := anObject
]

{ #category : #accessing }
GTInspectorPythonIVarNode >> rawValue [
	^ pythonObject
]

{ #category : #accessing }
GTInspectorPythonIVarNode >> variableTag [
	^ 'attribute'
]
