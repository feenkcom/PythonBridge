Extension { #name : #P3GGenerable }

{ #category : #'*PythonBridge' }
P3GGenerable >> gtViewPython3CodeIn: composite [
	<gtView>
	^ composite textEditor
		title: 'Python 3 code';
		priority: 30;
		text: [ self generate ]
]

{ #category : #'*PythonBridge' }
P3GGenerable >> isLanguageLinkValue [
	^ true
]

{ #category : #'*PythonBridge' }
P3GGenerable >> isPythonGenerable [
	^ true
]
