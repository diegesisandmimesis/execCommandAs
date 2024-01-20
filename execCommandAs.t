#charset "us-ascii"
//
// execCommandAs.t
//
//	A mechanism for executing a command (as in a command string) as
//	an arbitrary actor.
//
//	Requires the outputToggle, modularExecuteCommand, and
//	moreFailureReports modules.
//
//
// USAGE
//
//	To execute the command >TAKE PEBBLE as the actor "alice":
//
//		execCommandAs(alice, 'take pebble');
//
//	To see if the command would succeed without changing the game
//	state:
//
//		execCommandAs(alice, 'take pebble', true);
//
//
#include <adv3.h>
#include <en_us.h>

#include "execCommandAs.h"

// Module ID for the library
execCommandAsModuleID: ModuleID {
        name = 'execCommandAs Library'
        byline = 'Diegesis & Mimesis'
        version = '1.0'
        listingOrder = 99
}

// Execute a command as the given actor.
// First arg is an Actor instance, second arg is a command string (the
// equivalent a player's typed command, like "take lamp").
// Optional third arg is a test-only flag.  If boolean true, execCommandAs()
// will test the given command and return boolean true if it would succeed,
// boolean nil otherwise.
execCommandAs(actor, cmd, testOnly?) {
	local toks;

	if((actor == nil) || (cmd == nil))
		return(nil);

	if((toks = cmdTokenizer.tokenize(cmd)) == nil)
		return(nil);

	if(testOnly == true) {
		return(checkExecCommand(actor, actor, toks, true));
	} else {
		return(conditionalExecCommandAs(actor, actor, toks, true));
	}
}

// Check to see if a command would succeed.  If it would, then execute
// it "for real".
conditionalExecCommandAs(src, dst, toks, first) {
	if(!checkExecCommand(src, dst, toks, first))
		return(nil);

#ifdef MODULAR_EXECUTE_COMMAND_H
	modularExecuteCommand.execCommand(src, dst, toks, true);
#else // MODULAR_EXECUTE_COMMAND_H
	executeCommand(src, dst, toks, true);
#endif // MODULAR_EXECUTE_COMMAND_H

	return(true);
}

// Returns boolean true if the command would succeed, nil otherwise.
checkExecCommand(src, dst, toks, first) {
	local tr;

	if((tr = execCommandWithUndo(src, dst, toks, first)) == nil)
		return(nil);
	return(!tr.isFailure);
}

// Savepoint, execute the command with no output, and then undo.
// Returns the transcript of the hypothetical action (or nil on exception).
execCommandWithUndo(src, dst, toks, first) {
	local f, tr;

	tr = gTranscript;

	// Save the state of the output filter.
	f = gOutputCheck;

	try {
		savepoint();
		gTranscript = new CommandTranscript();

		// Turn the output filter on.
		gOutputOff;

#ifdef MODULAR_EXECUTE_COMMAND_H
		if(modularExecuteCommand.execCommand(src, dst, toks, first)
			!= true) {
			return(nil);
		}
#else // MODULAR_EXECUTE_COMMAND_H
		executeCommand(src, dst, toks, first);
#endif // MODULAR_EXECUTE_COMMAND_H

		return(gTranscript);
	}

	catch(Exception e) {
		return(nil);
	}

	finally {
		undo();
		gTranscript = tr;

		// Restore the output filter to its prior state.
		gOutputSet(f);
	}
}
