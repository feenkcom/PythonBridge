Class {
	#name : #PBModuleInstallationPane,
	#superclass : #Object,
	#instVars : [
		'moduleName',
		'acceptAction',
		'cancelAction'
	],
	#category : #'PythonBridge-Pharo-UI'
}

{ #category : #accessing }
PBModuleInstallationPane >> acceptAction [
	^ acceptAction ifNil: [ 
		[ :aModel :aButton :aMemento :aDescription |
			aButton phlow spawnObject: self ] ]
]

{ #category : #accessing }
PBModuleInstallationPane >> acceptAction: anAction [
	acceptAction := anAction
]

{ #category : #converting }
PBModuleInstallationPane >> asElement [
	^ self asGtMagritteViewModel asElement padding: (BlInsets all: 10)
]

{ #category : #accessing }
PBModuleInstallationPane >> cancelAction [
	^ cancelAction ifNil: [ 
		[ :aModel :aButton :aMemento :aDescription | ] ]
]

{ #category : #accessing }
PBModuleInstallationPane >> cancelAction: anAction [
	cancelAction := anAction
]

{ #category : #magritte }
PBModuleInstallationPane >> magritteAcceptAction [
	<magritteActionDescription>
	^ super magritteAcceptAction
		label: 'Install Python module';
		onSuccessCallback: (GtMagritteCallback new action: self acceptAction)
]

{ #category : #magritte }
PBModuleInstallationPane >> magritteCancelAction [
	<magritteActionDescription>
	^ super magritteCancelAction
		onSuccessCallback: (GtMagritteCallback new action: self cancelAction)
]

{ #category : #accessing }
PBModuleInstallationPane >> moduleName [
	^ moduleName
]

{ #category : #accessing }
PBModuleInstallationPane >> moduleName: aModelNameStringt [
	moduleName :=aModelNameStringt
]

{ #category : #magritte }
PBModuleInstallationPane >> moduleNameDescription [
	<magritteDescription>
	^ MAStringDescription new
		priority: 3;
		label: 'Module name';
		accessor: #moduleName;
		default: ''
]
