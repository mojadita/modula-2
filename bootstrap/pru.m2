(* pru.m2 -- test for DEFINITION MODULES inside another.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Thu Aug 23 12:22:11 EEST 2018
 * Copyright: (C) LUIS COLORADO.  All rights reserved.
 *)

DEFINITION MODULE Modula2;
  EXPORT QUALIFIED System;

  CONST A = 23.8;
		B = 2 * A + 57.42;
		C = 4*B - 117.0;
		D = (A + 23.8) * (C - 2.0 * D) + (2.0 * (C - 17.5));
		E = { 12, 5..8, 11};

  CONST CONST CONST
  VAR B, C: DOUBLE;

  DEFINITION MODULE System;
	EXPORT QUALIFIED In, Out, Err;
	TYPE FILE;  (* Opaque file type *)
	VAR In, Out, Err: FILE;
  END System;

END Modula2.