%{
/* m2p.y -- parser for MODULA-2.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Tue Aug 21 08:10:26 EEST 2018
 * Based on the MODULA-2 report by N. Wirth, 1978.
 * See: https://doi.org/10.3929/ethz-a-000153014
 */

#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#include "m2p.h"
%}

%token AND ARRAY TBEGIN BY CASE CONST DEFINITION DIV DO ELSE ELSIF
%token END EXIT EXPORT FOR FROM IF IMPORT IN LOOP
%token MOD MODULE NOT OF OR POINTER PROCEDURE QUALIFIED RECORD
%token REPEAT TRETURN SET THEN TO TYPE UNTIL VAR WHILE WITH

%token ASSIGN LE GE DOTDOT
%token IDENT NUMBER

/* this token is returned when an error is detected in the
 * scanner. */
%token BAD_TOKEN

%%

compilation_unit: DEFINITION ModuleDeclaration '.'
	| IDENT ModuleDeclaration '.'
	| ModuleDeclaration '.'
	;

ModuleDeclaration: MODULE IDENT ';' END IDENT;

%%

int yyerror(char *msg)
{
	printf(F("Error: %s\n"), msg);
	return 0;
}
