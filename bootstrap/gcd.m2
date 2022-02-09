(* This is a very flourished Modula-2 program to calculate the
 * Greatest Common Divisor, based on Euclides' algorithm.
 * The program makes strong use of comments and the like to test
 * the different parts of a compiler.
 * Author: Luis Colorado <Luis.Colorado.Urcola@gmail.com>
 * Date: Mon Feb  7 18:27:11 EET 2022
 * Copyright: (C) 2022 Luis Colorado.  All rights reseved.
 * License: BSD.
 *)
MODULE gcd;
	(* This comment tries to demonstrate 
	 * nested comments
	(* Calculation of the greatest
	 * common divisor of two numbers *)
	 * And the external comment continues here
	 *)

	FROM InOut IMPORT ReadCard, WriteString, WriteLn, WriteCard;

	VAR
		x, y, z: CARDINAL;

		PROCEDURE PromptCardinal( (* Displays a prompt and inputs a
								   * value for a CARDINAL variable *)
				Prompt: ARRAY OF CHAR; (* Prompt string *)
				VAR TheVar: CARDINAL); (* Variable to be input *)
		BEGIN
			WriteString(Prompt); ReadCard(TheVar); WriteLn;
		END PromptCardinal;

		PROCEDURE ApplyGDCOnce( (* computes one step of GDC *)
				x, y: CARDINAL);
			VAR z: CARDINAL;
		BEGIN
			z := x MOD y;
			x := y;
			y := z;
		END ApplyCDCOnce; 

BEGIN
	PromptCardinal("x: ", x);
	PromptCardinal("y: ", y);

    WHILE y # 0 DO
		ApplyGDCOnce(x, y)
    END;

    WriteString('mcd = ');
	WriteCard(x, 6);
	WriteLn
END gcd.
