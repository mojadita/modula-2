(* pru.m2 -- test for DEFINITION MODULES inside another.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Thu Aug 23 12:22:11 EEST 2018
 * Copyright: (C) LUIS COLORADO.  All rights reserved.
 *)

DEFINITION MODULE Modula2;

  (* This is the list of qualified identifiers exported by this
   * module *)
  EXPORT QUALIFIED
     A, B, C, D, E, F, H, I;

  (* some of them are constants... *)
  CONST
     A = 23.8;
     B = 2 * A + 57.42;
     C = 4*B - 117.0;
     D = (A + 23.8)*(C - 2.0 * B) + (2.0*(C - 17.5));
     E = { 12, 5..8, 11 };
     F = "Hello" + ',' + " world" + 012C;
     (* next variable is not exported, but used in next
      * definition *)
     G = "(* THIS IS A COMMENT ENBEDDED IN A QUOTED STRING, AND"
         + " AS SUCH, it's not a comment *)";

  (* ... and some of them are global variables of the module *)
  VAR H, I: REAL;

  (* we export also one procedure *)
  PROCEDURE Catenate(
        VAR ToWhat: ARRAY OF CHAR; (* first parameter *)
        What: ARRAY OF CHAR); (* second parameter *)

END Modula2.
