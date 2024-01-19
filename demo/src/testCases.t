#charset "us-ascii"
//
// testCases.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the execCommandAs library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f testCases.t3m
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
++pebble: Thing 'small round pebble' 'pebble' "A small, round pebble. ";
+alice: Person 'Alice' 'Alice'
	"She looks like the first person you'd turn to in a problem. "
	isHer = true
	isProperName = true
;
++stone: Thing 'ordinary stone' 'stone' "An ordinary stone. ";

versionInfo: GameID;
gameMain: GameMainDef
	initialPlayerChar = me
	newGame() {
		showIntro();
		runGame(true);
	}
	showIntro() {
		"This demo provides a <b>&gt;FOOZLE</b> command.  It runs
		a number of tests, all of which should fail.
		<.p> ";
	}
;

DefineSystemAction(Foozle)
	execSystemAction() {
		_tryCmd(alice, 'drop pebble', true);
		_tryCmd(alice, 'take stone', true);
		_tryCmd(alice, 'n', true);

		// Will "succeed" without modularExecuteCommand
		_tryCmd(alice, 'take rock', true);
		_tryCmd(alice, 'kiss player', true);
		_tryCmd(alice, 'attack player', true);

		// Will "succeed" without moreFailureReports
		_tryCmd(alice, 'take pebble', true);
		_tryCmd(alice, 'kiss stone', true);
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
