#charset "us-ascii"
//
// sample.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the execCommandAs library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f makefile.t3m
//
// ...or the equivalent, depending on what TADS development environment
// you're using.
//
// This "game" is distributed under the MIT License, see LICENSE.txt
// for details.
//
#include <adv3.h>
#include <en_us.h>

#include "execCommandAs.h"

startRoom: Room 'Void' "This is a featureless void.";
+me: Person;
+pebble: Thing 'small round pebble' 'pebble' "A small, round pebble. ";
+alice: Person 'Alice' 'Alice'
	"She looks like the first person you'd turn to in a problem. "
	isHer = true
	isProperName = true
;

versionInfo: GameID;
gameMain: GameMainDef
	initialPlayerChar = me
	newGame() {
		showIntro();
		runGame(true);
	}
	showIntro() {
		"This demo provides a <b>&gt;FOOZLE</b> command.  If
		first tests and then executes the command <q>take pebble</q>
		with Alice.
		<.p> ";
	}
;

DefineSystemAction(Foozle)
	execSystemAction() {
		_tryCmd(alice, 'take pebble', true);
		_tryCmd(alice, 'take pebble');
	}
	_tryCmd(actor, cmd, testOnly?) {
		"<<actor.name>> <<(testOnly ? 'testing' : 'trying')>>
			<q><<toString(cmd)>></q>: ";
		if(execCommandAs(actor, cmd, testOnly) == true) {
			"success.\n ";
		} else {
			"failed.\n ";
		}
	}
;
VerbRule(Foozle) 'foozle': FoozleAction VerbPhrase = 'foozle/foozling';
