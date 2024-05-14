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
				spec repository: 'github://feenkcom/OSSubprocess:main/repository' ];
			baseline: 'Python3Generator' with: [
				spec repository: 'github://juliendelplanque/Python3Generator:v2.0.0/src' ];
			baseline: 'NeoJSON' with: [
				spec repository: 'github://svenvc/NeoJSON:master/repository' ];
			baseline: 'MessagePack' with: [
				spec repository: 'github://feenkcom/msgpack-smalltalk:main/repository' ].
		spec 
			package: 'PythonBridge' with: [
				spec requires: #('OSSubprocess' 'Python3Generator' ). ];
			package: 'PythonBridge-Pharo' with: [
				spec requires: #('PythonBridge' 'MessagePack' ). ];
			package: 'PythonBridge-Bootstrap' with: [
				spec requires: #('PythonBridge' ). ]. ].

]
