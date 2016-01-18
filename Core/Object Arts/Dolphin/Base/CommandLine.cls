"Filed out from Dolphin Smalltalk 7"!

Object subclass: #CommandLine
	instanceVariableNames: 'arguments argv optArg optIndex optOpt optionPrefixChars options parsingArg parsingArgStream parsingOptionStream parsingRules'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
CommandLine guid: (GUID fromString: '{4E9D5C42-1049-4F31-862C-CB56225AA08A}')!
CommandLine comment: 'Instances of CommandLine can be used to parse command line options and arguments. 

The implementation is guided by and modeled on getopt() in Unix (http://www.gnu.org/software/libc/manual/html_node/Using-Getopt.html), but also has a simpler API. 

The description of the options is similar to getopt(), basically a string of characters that are allowed options with a $: following those that require an arguments.

From a CMD shell in the Dolphin directory, launch the development image with the following:

C:\Dolphin>Dolphin7 DPRO.img7 -a -b -c foo bar

Then, in a workspace evalute the following:

| commandLine options arguments |
commandLine := CommandLine options: ''abc:''.
options := commandLine options.	"a Dictionary($c -> ''foo'' $a -> nil $b -> nil)"
arguments := commandLine arguments. "#(''bar'')"'!
!CommandLine categoriesForClass!Kernel-Objects! !
!CommandLine methodsFor!

arguments

	^arguments!

getOpt: aString
	"http://www.gnu.org/software/libc/manual/html_node/Using-Getopt.html"

	| option |
	self options: aString.
	options size < optIndex ifTrue: [^nil].
	(option := options at: optIndex) ifNil: [
		optIndex := optIndex + 1.
		options size < optIndex ifTrue: [^nil].
		option := options at: optIndex.
	].
	optIndex := optIndex + 1.
	option key == $? ifTrue: [
		optArg := nil.
		optOpt := option value.
	] ifFalse: [
		optArg := option value.
		optOpt := nil.
	].
	^option key!

initialize: anArray

	argv := anArray.
	self assert: [2 <= argv size].
	optIndex := 1.
	optionPrefixChars := '-/'.!

optArg

	^optArg!

options
	"Answers a dictionary where key is the option and value is
		nil if no argument allowed
		empty if optional argument missing
		otherwise value of optional or required argument"

	| dict |
	dict := Dictionary new.
	options do: [:each | 
		each key ~~ $? ifTrue: [
			dict at: each key put: each value.
		].
	].
	^dict!

options: aString
	"http://www.gnu.org/software/libc/manual/html_node/Using-Getopt.html"

	parsingRules := self rulesFrom: aString.
	self parse.!

optOpt

	^optOpt!

parse

	arguments := OrderedCollection new.
	options := OrderedCollection new.
	parsingArgStream := (ReadStream on: argv) 
		next; 	"exe"
		next; 	"img7"
		yourself.
	[parsingArgStream atEnd] whileFalse: [	"iterate over the argv array"
		self parseNextArg.
	].
	arguments := arguments asArray.!

parseNextArg

	parsingArg := parsingArgStream next.
	(1 < parsingArg size and: [optionPrefixChars includes: parsingArg first]) ifFalse: [	"no prefix means treat as an argument rather than as an option"
		arguments add: parsingArg.
		^self
	].
	parsingOptionStream := (ReadStream on: parsingArg) 
		next; 	"Prefix character ($/ or $-)"
		yourself.
	[parsingOptionStream atEnd] whileFalse: [	"one argv can have multiple options (-ab is equivalent to -a -b)"
		self parseNextOption.
	].
!

parseNextOption

	| argRequired char optionArg rule |
	char := parsingOptionStream next.
	(parsingArg size == 2 and: [(parsingArg at: 1) == (parsingArg at: 2)]) ifTrue: [	"-- is a signal to treat everything following as arguments, not options"
		arguments addAll: parsingArgStream upToEnd.
		^self
	].
	rule := parsingRules 
		detect: [:each | each key == char] 
		ifNone: [	"Unrecognized option"
			options add: $? -> char.
			^self
		].
	argRequired := rule value.
	argRequired ifNil: [	"simple option without an argument"
		options add: char -> nil.
		^self
	].
	"option has an optional or required argument"
	optionArg := parsingOptionStream upToEnd.	"option argument can follow immediately (-xabc)"
	(optionArg isEmpty and: [parsingArgStream atEnd not]) ifTrue: [	"look for option argument in next argv"
		optionArg := parsingArgStream peek.
		(optionPrefixChars includes: optionArg first) ifTrue: [	"next argument begins with prefix character, so another option"
			optionArg := ''.		"option does not have an argument"
		] ifFalse: [
			parsingArgStream next.	"argument associated with option"
		].
	].
	(argRequired and: [optionArg isEmpty]) ifTrue: [	"error if required argument is not present"
		optionArg := char. 
		char := $?.
	].
	options add: char -> optionArg.	"save option and argument"!

rulesFrom: aString
	"Answer an array "

	| optionsStream rules |
	optionsStream := ReadStream on: aString.
	rules := OrderedCollection new.
	[optionsStream atEnd] whileFalse: [
		| argRequired char |
		argRequired := nil.	"initially assume that argument not allowed"
		char := optionsStream next. 
		 optionsStream peek == $: ifTrue: [
			argRequired := (optionsStream next; peek) ~~ $:.	": means argument is required; :: means argument is optional"
		].
		rules add: char -> argRequired.
	].
	^rules
! !
!CommandLine categoriesFor: #arguments!accessing!public! !
!CommandLine categoriesFor: #getOpt:!getopt protocol!public! !
!CommandLine categoriesFor: #initialize:!private! !
!CommandLine categoriesFor: #optArg!getopt protocol!public! !
!CommandLine categoriesFor: #options!accessing!public! !
!CommandLine categoriesFor: #options:!public! !
!CommandLine categoriesFor: #optOpt!getopt protocol!public! !
!CommandLine categoriesFor: #parse!private! !
!CommandLine categoriesFor: #parseNextArg!private! !
!CommandLine categoriesFor: #parseNextOption!private! !
!CommandLine categoriesFor: #rulesFrom:!private! !

!CommandLine class methodsFor!

argv: anArray
	"Constructor called directly only in testing"

	^super new
		initialize: anArray;
		yourself!

new
	"Generally the #options: constructor should be used"

	^self argv: SessionManager current argv!

options: aString
	"http://www.gnu.org/software/libc/manual/html_node/Using-Getopt.html"

	^self new
		options: aString;
		yourself! !
!CommandLine class categoriesFor: #argv:!public! !
!CommandLine class categoriesFor: #new!public! !
!CommandLine class categoriesFor: #options:!public! !
