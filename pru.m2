(* ProcessScheduler.m2 --- Borrowed from the report on the MODULA-2 language
 * from Niklaus Wirth.
 * Adapted for the compiler by Luis Colorado.
 *)
IMPLEMENTATION MODULE ProcessScheduler;
	(* N. Wirth. 29.1.80 *)
	FROM SYSTEM IMPORT PROCESS, ADDRESS, NEWPROCESS, TRANSFER;
	FROM Storage IMPORT ALLOCATE;

	TYPE SIGNAL = POINTER TO ProcessDescriptor;
		ProcessDescriptor =
			RECORD ready: BOOLEAN;
				pr:		PROCESS;
				next:	SIGNAL; (* ring *)
				queue:	SIGNAL; (* waiting queue *)
			END ;

	VAR cp: SIGNAL; (* current (* process *) *)

	PROCEDURE StartProcess(P: PROC; A: ADDRESS; n: CARDINAL);
		(* start P with workspace A of length n *)
		VAR t: SIGNAL;
	BEGIN t := cp; NEW(cp);
		WITH cp^ DO
			next := t^.next; ready := TRUE; queue := NIL; t^.next := cp
		END;
		NEWPROCESS(P, A, n, cp^.pr); TRANSFER(t^.pr, cp^.pr)
	END StartProcess;

	PROCEDURE SEND(VAR s: SIGNAL);
		(* resume first process waiting for s *)
		VAR t: SIGNAL;
	BEGIN
		IF S # NIL THEN
			t := cp; cp := s;
			WITH cp^ DO
				s := queue; ready := TRUE; queue := NIL
			END ;
			TRANSFER(t^.pr, cp^.pr)
		END
	END SEND;

	PROCEDURE WAIT(VAR s: SIGNAL);
		VAR t0, t1: SIGNAL;
	BEGIN (* insert current process at end of queue *)
		IF s = NIL THEN s := cp ELSE
			t0 := s;
			LOOP t1 := t0^.queue;
				IF t1 = NIL THEN t0^.queue := cp; EXIT END ;
				t0 := t1
			END
		END ;
		cp^.queue := NIL; cp^.ready := FALSE;
		t0 := cp; (* now find next ready process *)
		LOOP cp := cp^.next;
			IF cp^.ready THEN EXIT END ;
			IF cp = t0 THEN HALT (* deadlock *) END
		END ;
		TRANSFER(t0^.pr, cp^.pr)
	END WAIT;

	PROCEDURE Awaited(S: SIGNAL): BOOLEAN;
	BEGIN RETURN s # NIL
	END Awaited;

	PROCEDURE InitSignal(VAR s: SIGNAL);
	BEGIN s := NIL
	END InitSignal;

BEGIN NEW(cp);
	WITH cp^  DO
		next := cp; ready := TRUE; queue := NIL
	END
END ProcessScheduler.
