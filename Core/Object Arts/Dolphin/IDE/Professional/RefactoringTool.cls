"Filed out from Dolphin Smalltalk X6.1"!

Object subclass: #RefactoringTool
	instanceVariableNames: 'presenter'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RefactoringTool guid: (GUID fromString: '{838C8C37-C249-4DB4-B324-65CB5BABDC40}')!
RefactoringTool comment: 'RefactoringTool is the abstract class of plugins used to add refactoring functionality to browsers and other coding tools in the Dolphin IDE.

Note that RefactoringTool is neither a presenter nor a model, but it is a <commandTarget>.

Instance Variables:
	presenter		<presenter> hosting the refactoring tool. Its type will depend on the subclass.

'!
!RefactoringTool categoriesForClass!Unclassified! !
!RefactoringTool methodsFor!

convertTempToInstVar: aStVariableNode 
	"Private - Command to invoke the 'Convert to Instance Variable' code refactoring
	on the specified temporary variable name."

	presenter performMethodRefactoring: 
			[:method | 
			self systemModel 
				convertTemporaryToInstanceVariable: aStVariableNode name
				in: method methodClass
				selector: method selector]!

inlineParameter: aStVariableNode 
	presenter performMethodRenameRefactoring: 
			[:method | 
			self systemModel 
				inlineParameter: aStVariableNode name
				from: method selector
				in: method methodClass]!

onAboutToDisplayMenu: aMenu 
	"The pop-up <Menu> argument is about to be displayed. This is our opportunity to update it,
	e.g. to add/remove items."

	!

parseTree
	^presenter parseTree!

queryCommand: aCommandQuery 
	"Private - Enter details about a potential command for the receiver into the
	<CommandQuery>."

	| selector cmd |
	cmd := aCommandQuery command.
	cmd isNil ifTrue: [^false].
	selector := cmd asSymbol.
	selector == #renameIt 
		ifTrue: 
			[cmd := self renameItCommand.
			cmd isNil 
				ifTrue: 
					[aCommandQuery
						isEnabled: false;
						text: (aCommandQuery commandDescription menuText expandMacrosWith: 'It').
					^true]].
	^self queryCommand: aCommandQuery command: cmd!

queryCommand: aCommandQuery command: aCommand 
	^self subclassResponsibility!

removeParameter: aStVariableNode 
	"Private - Command to invoke the 'Remove Method Parameter' refactoring on the specified
	argument name."

	presenter 
		performMethodRenameRefactoring: [:method | self removeParameter: aStVariableNode from: method]!

removeParameter: aStVariableNode from: method 
	^self systemModel 
		removeParameter: aStVariableNode name
		from: method selector
		in: method methodClass
		environment: presenter searchEnvironment!

renameIt
	"Context-sensitive #renameIt command, usually bound to the F2 key"

	self renameItCommand value: self!

renameItCommand
	^self subclassResponsibility!

renameTemporary: aStVariableNode 
	"Private - Invoke the 'Rename Temporary' code refactoring to rename the temporary variable
	identified by the specified variable node."

	presenter performMethodRefactoring: 
			[:method | 
			self systemModel 
				renameTemporary: aStVariableNode
				to: nil
				in: method methodClass
				selector: method selector]!

setPresenter: aPresenter 
	presenter := aPresenter!

systemModel
	^Smalltalk developmentSystem! !
!RefactoringTool categoriesFor: #convertTempToInstVar:!public!refactoring! !
!RefactoringTool categoriesFor: #inlineParameter:!private!refactoring! !
!RefactoringTool categoriesFor: #onAboutToDisplayMenu:!event handling!public! !
!RefactoringTool categoriesFor: #parseTree!accessing!private! !
!RefactoringTool categoriesFor: #queryCommand:!commands!public! !
!RefactoringTool categoriesFor: #queryCommand:command:!commands!private! !
!RefactoringTool categoriesFor: #removeParameter:!operations!private!refactoring! !
!RefactoringTool categoriesFor: #removeParameter:from:!operations!private!refactoring! !
!RefactoringTool categoriesFor: #renameIt!commands!public!refactoring! !
!RefactoringTool categoriesFor: #renameItCommand!private!refactoring! !
!RefactoringTool categoriesFor: #renameTemporary:!operations!private!refactoring! !
!RefactoringTool categoriesFor: #setPresenter:!initializing!private! !
!RefactoringTool categoriesFor: #systemModel!constants!public! !

RefactoringTool methodProtocol: #commandTarget attributes: #(#readOnly) selectors: #(#queryCommand:)!

!RefactoringTool class methodsFor!

forPresenter: aPresenter 
	^(self new)
		setPresenter: aPresenter;
		yourself! !
!RefactoringTool class categoriesFor: #forPresenter:!instance creation!public! !

