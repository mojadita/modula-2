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
%token END EXIT EXPORT FOR FROM IF IMPLEMENTATION IMPORT IN LOOP
%token MOD MODULE NOT OF OR POINTER PROCEDURE QUALIFIED RECORD
%token REPEAT TRETURN SET THEN TO TYPE UNTIL VAR WHILE WITH

%token ASSIGN LE GE DOTDOT
%token IDENT NUMBER

/* this token is returned when an error is detected in the
 * scanner. */
%token BAD_TOKEN

%%

CompilationUnit
	: DefinitionModule
	| IMPLEMENTATION ProgramModule ';'
	| ProgramModule ';'
	;

/* 5. Constant declarations */

ConstantDeclaration: IDENT '=' ConstExpression ;

ConstExpression
      : SimpleConstExpr relation SimpleConstExpr
      | SimpleConstExpr

relation: '=' | '#' | '<' | LE | '>' | GE | IN ;

SimpleConstExpr: ConstTerm_list ;

ConstTerm_list: ConstTerm_list AddOperator ConstTerm
		| ConstTerm
		| '+' ConstTerm
		| '-' ConstTerm
		;

AddOperator: '+' | '-' | OR ;

ConstTerm: ConstTerm MulOperator ConstFactor
		| ConstFactor
		;

MulOperator: '*' | '/' | 'DIV' | 'MOD' | 'AND' | '&' ;

ConstFactor
	: qualident
	| number
	| string
	| set
	| '(' ConstExpression ')'
	| NOT ConstFactor ;

set: qualident_opt '{' element_list_opt '}';

qalident_opt
		: qualident
		| /* empty */
		;

element_list
		: element_list ',' element
		| element
		;

element_list_opt: element_list
		| /* empty */
		;

element
		: ConstExpression DOTDOT ConstExpression
		| ConstExpression 
		;


/* 6. Type declarations */

TypeDeclaration
		: IDENT '=' type
		;

type
		: SimpleType
		| ArrayType
		| RecordType
		| SetType
		| PointerType
		| ProcedureType
		;

SimpleType
		: qualident
		| enumeration
		| SubrangeType
		;

/* 6.2. Enumerations */

enumeration
		: '(' IdentList ')'
		;

IdentList
		: IdentList ',' ident
		| ident
		;

/* 6.3. Subrange types */

SubrangeType
		: '[' ConstExpression DOTDOT ConstExpression ']'
		;

/* 6.4 Array types */

ArrayType
		: ARRAY SimpleType_list OF type;

SimpleType_list
		: SimpleType_list ',' SimpleType
		| SimpleType
		;

/* 6.5. Record types */

RecordType
		: RECORD
			FieldListSequence
		  END
		;

FieldListSequence
		: FieldListSequence ';' FieldList
		| FieldList
		;

FieldList
		: IdentList ':' type
		  | CASE case_ident_opt qualident OF
				variant_list
				else_fls
		    END'
		| /* empty */
		;

case_ident_opt
		: IDENT ':'
		| /* empty */
		;

variant_list
		: variant_list '|' variant
		| variant
		;

else_fls
		: ELSE FieldListSequence
		| /* empty */
		;

variant: CaseLabelList ':' FieldListSequence ;

CaseLabelList: CaseLabelList ',' CaseLabels
		| CaseLabels
		;
CaseLabels
		: ConstExpression DOTDOT ConstExpression
		| ConstExpression
		;

/* 6.6. Set types */

SetType: SET OF SimpleType ;

/* 6.7. Pointer types */

PointerType: POINTER TO type ;

/* 6.8 Procedure types */
/* TODO: I'm here. */

ProcedureType: 'PROCEDURE' [ FormalTypeList ] ;
FormalTypeList: '(' [ [ 'VAR' ] FormalType
	{ ',' [ 'VAR' ] FormalType } ] ')' [ ':' qualident ] ;

VariableDeclaration: IdentList ':' type ;

/* 8. Expressions */
/* 8.1. Operands */

designator: qualident { '.' ident | '[' ExpList ']' | '^' } ;
ExpList: expression { ',' expression } ;

/* 8.2 Operators */

expression: SimpleExpression [ relation SimpleExpression ] ;
SimpleExpression: [ '+' | '-' ] term { AddOperator term } ;
term: factor { MulOperator factor } ;
factor: number | string | set | designator [ ActualParameters ]
	| '(' expression ')' | 'NOT' factor ;
ActualParameters: '(' [ ExpList ] ')' ;

/* 9. Statements */

statement: [ assignment | ProcedureCall
	| IfStatement | CaseStatement | WhileStatement
	| RepeatStatement | LoopStatement | ForStatement
	| WithStatement | 'EXIT' | 'RETURN' [ expression ] ] ;

/* 9.1. Assignments */

assignment: designator ':=' expression ;

/* 9.2. Procedure calls */

ProcedureCall: designator [ ActualParameters ] ;

/* 9.3. Statement sequences */

StatementSequence: statement { ';' statement } ;

/* 9.4. If statement */

IfStatement:
	  'IF' expression 'THEN' StatementSequence
	{ 'ELSIF' expression 'THEN' StatementSequence }
	[ 'ELSE' StatementSequence ] 'END' ;

/* 9.5. Case statements */

CaseStatement: 'CASE' expression 'OF' case { '|' case }
	[ 'ELSE' StatementSequence ] 'END' ;
case: CaseLabelList ':' StatementSequence ;

/* 9.6. While statements */

WhileStatement: 'WHILE' expression 'DO' StatementSequence 'END' ;

/* 9.7. Repeat statements */

RepeatStatement: 'REPEAT' StatementSequence UNTIL expression ;

/* 9.8. For statements */

ForStatement: 'FOR' ident ':=' expression TO expression
	[ 'BY' ConstExpression ] 'DO' StatementSequence 'END' ;

/* 9.9. Loop statements */

LoopStatement: 'LOOP' StatementSequence 'END' ;

/* 9.10. With statements */

WithStatement: 'WITH' designator 'DO' StatementSequence 'END' ;

/* 10. Procedure declarations */

ProcedureDeclaration: ProcedureHeading ';' block ident;
ProcedureHeading: 'PROCEDURE' ident [ FormalParameters ] ;
block: { declaration } [ 'BEGIN' StatementSequence ] 'END' ;

declaration: 'CONST' { ConstantDeclaration ';' }
	| 'TYPE' { TypeDeclaration ';' }
	| 'VAR' { VariableDeclaration ';' }
	| ProcedureDeclaration ';'
	| ModuleDeclaration ';'
	;
/* 10.1. Formal parameters */

FormalParameters: '(' [ FPSection { ';' FPSection } ] ')' [ ':' qualident ] ;
FPSection: [ 'VAR' ] IdentList ':' FormalType ;
FormalType: [ 'ARRAY' 'OF' ] qualident ;

/* 11. Modules */

ModuleDeclaration: 'MODULE' ident [ priority ] ';' { import } [ export ] block ident ;

priority: '[' Const_Expression ']' ;
export: 'EXPORT' [ 'QUALIFIED' ] IdentList ';' ;
import: [ 'FROM' ident ] 'IMPORT' IdentList ';' ;

/* 14. Compilation Units */

DefinitionModule: 'DEFINITION' 'MODULE' ident ';' { import }
	[ export ] { definition } 'END' ident "." ;

definition: 'CONST' { ConstantDeclaration ';' }
	| 'TYPE' { ident [ '=' type ] ';' }
	| 'VAR' { VariableDeclaration ';' }
	| ProcedureHeading ';'
	;

ProgramModule: 'MODULE' ident [ priority ] ';' { import } block ident '.' ;

%%

int yyerror(char *msg)
{
	printf(F("Error: %s\n"), msg);
	return 0;
}
