Class {
	#name : #PBPharoManualProcess,
	#superclass : #LanguageLinkManualProcess,
	#category : #'PythonBridge-Pharo-Processes'
}

{ #category : #accessing }
PBPharoManualProcess >> gtPackage [
	"Answer the name of the Python package where top level gt code lives as a P3GIdentifier"
	
	^ #gtoolkit_bridge asP3GI => #gtoolkit
]

{ #category : #'gt - extensions' }
PBPharoManualProcess >> gtViewDetailsIn: composite [
	<gtView>
	^ composite columnedList
		title: 'Details';
		priority: 40;
		items: [ {
			{ 'running' . self isRunning }.
			{ 'server address' . self application settings serverSocketAddress }.
			{ 'debug mode' . self debugMode }
		} ];
		column: 'Key' text: #first weight: 0.5;
		column: 'Value' text: #second;
		send: #last;
		actionUpdateButton
]

{ #category : #'gt - extensions' }
PBPharoManualProcess >> gtViewInstalledModulesIn: composite [
	<gtView>
	^ composite empty
]
