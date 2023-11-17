Class {
	#name : #BaselineOfPythonBridge,
	#superclass : #BaselineOf,
	#category : #BaselineOfPythonBridge
}

{ #category : #baseline }
BaselineOfPythonBridge >> baseline: spec [
	<baseline>
	spec for: #'common' do: [
		spec
			baseline: 'OSSubprocess' with: [
				spec repository: 'github://feenkcom/OSSubprocess:v1.1.22/repository' ].
		spec
			baseline: 'Python3Generator' with: [
				spec repository: 'github://juliendelplanque/Python3Generator:v2.0.0/repository' ].
		spec
			baseline: 'NeoJSON' with: [
				spec repository: 'github://svenvc/NeoJSON:2b0c0d20bc68965c600179f3da16bcace727e8b6/repository' ].
		spec
			baseline: 'MessagePack' with: [
				spec repository: 'github://feenkcom/msgpack-smalltalk:v1.3.5/repository' ].

		spec package: 'PythonBridge' with: [
			spec requires: #('OSSubprocess' 'Python3Generator') ].
		spec package: 'PythonBridge-Pharo' with: [
			spec requires: #('PythonBridge' 'MessagePack') ].
		spec package: 'PythonBridge-Bootstrap' with: [
			spec requires: #('PythonBridge') ].
	]
]
