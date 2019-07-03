MODULE mcd;
(* Cálculo del máximo común divisor de dos números *)

FROM InOut IMPORT ReadCard, WriteString,
	WriteLn, WriteCard;
VAR
	x, y: CARDINAL;

BEGIN
	WriteString('x: '); ReadCard(x); WriteLn;
	WriteString('y: '); ReadCard(y); WriteLn;
	WHILE x # y DO
		IF x > y THEN x := x - y
				 ELSE y := y - x
		END
	END;
	WriteString('mcd = '); WriteCard(x, 6);
	WriteLn
END mcd.