Class {
	#name : #PBApplicationExamples,
	#superclass : #Object,
	#instVars : [
		'server'
	],
	#category : #'PythonBridge-Pharo-Examples'
}

{ #category : #examples }
PBApplicationExamples class >> approximatePiInPython [
	<gtExample>
	<after: #stopPBApplication>

	| approximatedPi |
	
	approximatedPi := self  runningPBApplication newCommandFactory
		<< (P3GBinaryOperator new
				left: 333;
				right: 106;
				operator: $/;
				yourself);
		sendAndWait.
		
	self assert: (approximatedPi closeTo: Float pi).
	
	^ approximatedPi
]

{ #category : #examples }
PBApplicationExamples class >> runningPBApplication [
	<gtExample>
	<after: #stopPBApplication>
	
	PBApplication start.
	
	self assert: PBApplication isWorking.
	
	^ PBApplication uniqueInstance
]

{ #category : #utilities }
PBApplicationExamples class >> stopPBApplication [
	PBApplication stop
]

{ #category : #examples }
PBApplicationExamples >> additionInPython [
	<gtExample>
	<after: #stopServer>

	| x y pythonSum |
	
	x := 100 atRandom.
	y := 100 atRandom.
	
	pythonSum := self runningServer newCommandFactory
			<< (P3GBinaryOperator new
					left: x;
					right: y;
					operator: $+;
					yourself);
			sendAndWait.
	
	self assert: pythonSum equals: x + y
]

{ #category : #examples }
PBApplicationExamples >> runningServer [
	<gtExample>
	<after: #stopServer>
	
	server ifNotNil: [ ^ server ].
	
	server := PBApplication new.
	
	server start.
	
	self assert: server isRunning.
	
	^ server
]

{ #category : #examples }
PBApplicationExamples >> sortingInPython [
	<gtExample>
	<after: #stopServer>

	| numbers pythonSorted |
	
	numbers := (1 to: 10) collect: [ :_ | 100 atRandom ].
	
	pythonSorted := self runningServer newCommandFactory
			<< (#sorted callWith: { numbers });
			sendAndWait.
	
	self assert: pythonSorted equals: numbers sorted
]

{ #category : #utilities }
PBApplicationExamples >> stopServer [
	server ifNotNil: [ 
		server stop.
		server := nil ]
]
