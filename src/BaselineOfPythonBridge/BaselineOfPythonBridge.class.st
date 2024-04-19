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
				spec repository: 'github://feenkcom/OSSubprocess:v1.1.23/repository' ].
		spec
			baseline: 'Python3Generator' with: [
				spec repository: 'github://juliendelplanque/Python3Generator:v2.0.0/repository' ].
		spec
			baseline: 'NeoJSON' with: [
				spec repository: 'github://svenvc/NeoJSON:19bb4ca4c6f68defee93bea24efddee8a8122ab4/repository' ].
		spec
			baseline: 'MessagePack' with: [
				spec repository: 'github://feenkcom/msgpack-smalltalk:v1.3.6/repository' ].

		spec package: 'PythonBridge' with: [
			spec requires: #('OSSubprocess' 'Python3Generator') ].
		spec package: 'PythonBridge-Pharo' with: [
			spec requires: #('PythonBridge' 'MessagePack') ].
		spec package: 'PythonBridge-Bootstrap' with: [
			spec requires: #('PythonBridge') ].
	]
]
