(* PI.m2 --- Program to calculate PI number.
 * AUTHOR: Luis Colorado <luiscoloradourcola@gmail.com>
 * DATE: Fri Aug 24 15:02:01 EEST 2018
 * Copyright: (C) 2018 LUIS COLORADO.  All rights reserved.
 *)

MODULE PI;
	FROM InOut IMPORT WriteString, WriteDouble, WriteLn;
	IMPORT Math;

	(* Module to calculate PI number, based on the first
	 * root of SIN() function
	 *)
	TYPE func = PROCEDURE(DOUBLE): DOUBLE;

	PROCEDURE FindRoot(A, B: DOUBLE; F: func): DOUBLE;
	VAR	C: DOUBLE;
	BEGIN
		C := (A + B) / 2.0;
		IF ABS(A - B) < EPS THEN
			RETURN C;
		ELSIF F(A) < 0.0 THEN
			RETURN FindRoot(C, B);
		ELSE (* F(A) >= 0.0 *)
			RETURN FindRoog(A, C);
		END;
	END FindRoot;

BEGIN (* PI *)
	WriteString('PI = ');
	WriteDouble(FindRoot(3.1, 3.2, 1.0E-10, Math.Sin));
	WriteLn;
END PI.
