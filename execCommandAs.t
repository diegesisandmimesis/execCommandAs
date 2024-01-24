#charset "us-ascii"
//
// execCommandAs.t
//
//	A mechanism for executing a command (as in a command string) as
//	an arbitrary actor.
//
//	Requires the modularExecuteCommand moreFailureReports modules.
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
// Optional fourth arg will, if true, allow the executed command to "count
// against" the actor's nextRunTime.  By default the actor's nextRunTime
// will be set to be whatever it was before executing the command.  This
// is in the assumption that execCommandAs() will mostly be used to
// replace an actor's turn, and so the executed command should NOT make
// the actor's next turn occur any later.
execCommandAs(actor, cmd, testOnly?, leaveNextRunTime?) {
	local r, t, toks;

	if((actor == nil) || (cmd == nil))
		return(nil);

	if((toks = cmdTokenizer.tokenize(cmd)) == nil)
		return(nil);

	if(testOnly == true) {
		return(checkExecCommand(actor, actor, toks, true));
	} else {
		if(leaveNextRunTime != true)
			t = actor.nextRunTime;
		r = conditionalExecCommandAs(actor, actor, toks, true);
		if(leaveNextRunTime != true)
			actor.nextRunTime = t;
		return(r);
	}
}

// Check to see if a command would succeed.  If it would, then execute
// it "for real".
conditionalExecCommandAs(src, dst, toks, first) {
	if(!checkExecCommand(src, dst, toks, first))
		return(nil);

	modularExecuteCommand.execCommand(src, dst, toks, true);

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
	local tr;

	tr = gTranscript;

	try {
		savepoint();

		gTranscript = new CommandTranscript();
		execCommandAsFilter.active = true;

		if(modularExecuteCommand.execCommand(src, dst, toks, first)
			!= true) {
			return(nil);
		}

		return(gTranscript);
	}

	catch(Exception e) {
		return(nil);
	}

	finally {
		undo();
		gTranscript = tr;
		execCommandAsFilter.active = nil;
	}
}

// Output filter that suppressed all output.
// We use this in execCommandWithUndo() to suppress output without
// disabling the transcript, because we want to save the results of
// reports.
execCommandAsFilter: OutputFilter, PreinitObject
	active = nil
	filterText(str, val) { return(active ? '' : inherited(str, val)); }
	execute() { mainOutputStream.addOutputFilter(self); }
;
