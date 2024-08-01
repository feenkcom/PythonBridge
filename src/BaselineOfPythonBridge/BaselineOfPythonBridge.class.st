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
			baseline: 'Python3Generator' with: [
				spec repository: 'github://juliendelplanque/Python3Generator:v2.0.0/src' ].
		spec
			baseline: 'NeoJSON' with: [
				spec repository: 'github://svenvc/NeoJSON:f5652fb238989c9b4287179ff0725eab25765033/repository' ].
		spec
			baseline: 'MessagePack' with: [
				spec repository: 'github://feenkcom/msgpack-smalltalk:v1.3.6/repository' ].

		spec package: 'PythonBridge' with: [
			spec requires: #('Python3Generator') ].
		spec package: 'PythonBridge-Pharo' with: [
			spec requires: #('PythonBridge' 'MessagePack') ].
		spec package: 'PythonBridge-Bootstrap' with: [
			spec requires: #('PythonBridge') ].
	]
]
