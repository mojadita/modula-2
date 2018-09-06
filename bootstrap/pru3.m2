(* PI.m2 --- Program to calculate PI number.
 * AUTHOR: Luis Colorado <luiscoloradourcola@gmail.com>
 * DATE: Fri Aug 24 15:02:01 EEST 2018
 * Copyright: (C) 2018 LUIS COLORADO.  All rights reserved.
 *)

MODULE PI; (* calculate root of Math.Sin(x), x >= 3.1, x < 3.2 *)

	FROM InOut IMPORT WriteString, WriteReal, WriteLn;
	FROM Math IMPORT Sin;

	(* Module to calculate PI number, based on the first
	 * root of the Sin() function
	 *)
	TYPE Func = PROCEDURE(REAL): DOUBLE;

	PROCEDURE FindRoot(a, b, eps: REAL; f: Func): REAL;
	VAR	c: REAL;
	BEGIN
		c := (a + b) / 2.0;
		IF ABS(a - b) < eps THEN
			RETURN c;
		ELSIF f(a) < 0.0 THEN
			RETURN FindRoot(c, b, eps, f);
		ELSE (* f(a) >= 0.0 *)
			RETURN FindRoog(a, c, eps, f);
		END;
	END FindRoot;

BEGIN (* PI *)
	WriteString('PI = ');
	WriteDouble(
        FindRoot(
            3.1,
            3.2,
            1.0E-10,
            Sin),+
        0, (* field size *)
        8); (* decimal digits *)
	WriteLn;
END PI.
(* EOF *)
