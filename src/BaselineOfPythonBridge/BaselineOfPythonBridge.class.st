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
				spec repository: 'github://feenkcom/OSSubprocess:v1.1.21/repository' ].
		spec
			baseline: 'Python3Generator' with: [
				spec repository: 'github://juliendelplanque/Python3Generator:v2.0.0/repository' ].
		spec
			baseline: 'NeoJSON' with: [
				spec repository: 'github://svenvc/NeoJSON:2415f508808bc0d29ed74e3e816f59bfc8aac895/repository' ].
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
