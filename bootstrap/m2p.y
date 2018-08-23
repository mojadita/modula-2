%{ 
/* m2p.y -- parser for MODULA-2.
 * Date: Tue Aug 21 08:10:26 EEST 2018
 * Based on the MODULA-2 report by N. Wirth, 1978.
 * See: https://doi.org/10.3929/ethz-a-000153014
 */

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <stravl.h>

#include "m2p.h"

%}

%token AND ARRAY TBEGIN BY CASE CONST DEFINITION DIV DO ELSE ELSIF
%token END EXIT EXPORT FOR FROM IF IMPLEMENTATION IMPORT IN LOOP
%token MOD MODULE NOT OF OR POINTER PROCEDURE QUALIFIED RECORD
%token REPEAT TRETURN SET THEN TO TYPE UNTIL VAR WHILE WITH

%token ASSIGN LE GE NE RANGE
%token IDENT NUMBER CHARLIT STRING QUAL_IDENT

/* this token is returned when an error is detected in the
 * scanner. */
%token BAD_TOKEN

%%

CompilationUnit
		: DefinitionModule '.'
		| IMPLEMENTATION ProgramModule '.'
		| ProgramModule '.'
		;

qualident
		: qualifier '.' IDENT
		| IDENT
		;

qualifier
		: qualifier '.' QUAL_IDENT
		| QUAL_IDENT
		;

/* 5. Constant declarations */

ConstantDeclaration
		: IDENT '=' ConstExpression
		;

ConstExpression
		: SimpleConstExpr relation SimpleConstExpr
		| SimpleConstExpr
		;

relation
		: '='
		| '#'
		| NE
		| '<'
		| LE
		| '>'
		| GE
		| IN
		;

SimpleConstExpr
		: ConstTerm_list
		;

ConstTerm_list
		: ConstTerm_list AddOperator ConstTerm
		| add_op_opt ConstTerm
		;

add_op_opt
		: '+'
		| '-'
		| /* empty */
		;

AddOperator
		: '+'
		| '-'
		| OR
		;

ConstTerm
		: ConstTerm MulOperator ConstFactor
		| ConstFactor
		;

MulOperator
		: '*'
		| '/'
		| DIV
		| MOD
		| AND
		| '&'
		;

ConstFactor
		: qualident
		| NUMBER
		| STRING
		| CHARLIT
		| set
		| '(' ConstExpression ')'
		| NOT ConstFactor
		;

set		: qualident '{' element_list_opt '}'
		| '{' element_list_opt '}'
		;

element_list_opt
		: element_list
		| /* empty */
		;

element_list
		: element_list ',' element
		| element
		;

element
		: ConstExpression RANGE ConstExpression
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
		: IdentList ',' IDENT
		| IDENT
		;

/* 6.3. Subrange types */

SubrangeType
		: '[' ConstExpression RANGE ConstExpression ']'
		;

/* 6.4 Array types */

ArrayType
		: ARRAY SimpleType_list OF type
		;

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
		| CASE case_ident OF
				variant_list
				ELSE_FieldListSequence
		  END
		| /* empty */
		;

case_ident
		: IDENT ':' qualident 
		| 			qualident
		;

variant_list
		: variant_list '|' variant
		| variant
		;

ELSE_FieldListSequence
		: ELSE FieldListSequence
		| /* empty */
		;

variant	: CaseLabelList ':' FieldListSequence
		;

CaseLabelList
		: CaseLabelList ',' CaseLabels
		| CaseLabels
		;

CaseLabels
		: ConstExpression RANGE ConstExpression
		| ConstExpression
		;

/* 6.6. Set types */

SetType	: SET OF SimpleType
		;

/* 6.7. Pointer types */

PointerType
		: POINTER TO type
		;

/* 6.8 Procedure types */

ProcedureType
		: PROCEDURE FormalTypeList
		| PROCEDURE
		;

FormalTypeList
		: paren_formal_parameter_type_list_opt ':' qualident
		| paren_formal_parameter_type_list_opt
		;

paren_formal_parameter_type_list_opt
		: '(' formal_parameter_type_list_opt ')'
		;

formal_parameter_type_list_opt
		: formal_parameter_type_list
		| /* EMPTY */
		;

formal_parameter_type_list
		: formal_parameter_type_list ',' formal_parameter_type
		| formal_parameter_type
		;

formal_parameter_type
		: VAR FormalType
		| FormalType
		;

VariableDeclaration
		: IdentList ':' type
		;

/* 8. Expressions */
/* 8.1. Operands */

designator
		: designator '.' IDENT
		| designator '[' ExpList ']'
		| designator '^'
		| qualident
		;

ExpList
		: ExpList ',' expression
		| expression
		;

/* 8.2 Operators */

expression
		: SimpleExpression relation SimpleExpression
		| SimpleExpression
		;

SimpleExpression
		: SimpleExpression AddOperator term
		| add_op_opt term
		;

term	: term MulOperator factor
		| factor
		;

factor	: NUMBER
		| STRING
		| CHARLIT
		| set
		| designator ActualParameters
		| designator
		| '(' expression ')'
		| NOT factor
		;

ActualParameters
		: '(' ExpList ')'
		| '(' ')'
		;

/* 9. Statements */

statement
		: assignment
		| ProcedureCall
		| IfStatement
		| CaseStatement
		| WhileStatement
		| RepeatStatement
		| LoopStatement
		| ForStatement
		| WithStatement
		| EXIT
		| TRETURN expression
		| TRETURN
		;

/* 9.1. Assignments */

assignment
		: designator ASSIGN expression
		;

/* 9.2. Procedure calls */

ProcedureCall
		: designator ActualParameters
		| designator
		;

/* 9.3. Statement sequences */

StatementSequence
		: StatementSequence ';' statement
		| statement
		;

/* 9.4. If statement */

IfStatement
		: IF expression THEN
			StatementSequence
		  elsif_seq
		  else_opt
		  END
		;

elsif_seq
		: elsif_seq ELSIF expression THEN StatementSequence
		| /* EMPTY */
		;

else_opt
		: ELSE StatementSequence
		| /* EMPTY */
		;

/* 9.5. Case statements */

CaseStatement
		: CASE expression OF
			case_list
			else_opt
		  END
		;

case_list
		: case_list '|' case
		| case
		;

case	: CaseLabelList ':' StatementSequence
		;

/* 9.6. While statements */

WhileStatement
		: WHILE expression DO
			StatementSequence
		  END
		;

/* 9.7. Repeat statements */

RepeatStatement
		: REPEAT
			StatementSequence
		  UNTIL expression
		;

/* 9.8. For statements */

ForStatement
		: FOR IDENT ASSIGN expression TO expression by_opt DO
			StatementSequence
		  END
		;

by_opt	: BY ConstExpression
		| /* empty */
		;

/* 9.9. Loop statements */

LoopStatement
		: LOOP
			StatementSequence
		  END
		;

/* 9.10. With statements */

WithStatement
		: WITH designator DO
			StatementSequence
		  END
		;

/* 10. Procedure declarations */

ProcedureDeclaration
		: ProcedureHeading ';'
			block IDENT
		;

ProcedureHeading
		: PROCEDURE IDENT FormalParameters_opt
		;

FormalParameters_opt
		: FormalParameters
		| /* empty */
		;

block: declaration_list_opt BEGIN_StatementSequence_opt END ;

declaration_list_opt
		: declaration_list_opt declaration
		| /* empty */
		;

BEGIN_StatementSequence_opt
		: TBEGIN StatementSequence
		| /* empty */
		;

declaration
		: CONST ConstantDeclaration_list_opt
		| TYPE TypeDeclaration_list_opt
		| VAR VariableDeclaration_list_opt
		| ProcedureDeclaration ';'
		| ModuleDeclaration ';'
		;

ConstantDeclaration_list_opt
		: ConstantDeclaration_list_opt ConstantDeclaration ';'
		| /* empty */
		;

TypeDeclaration_list_opt
		: TypeDeclaration_list_opt TypeDeclaration ';'
		| /* empty */
		;

VariableDeclaration_list_opt
		: VariableDeclaration_list_opt VariableDeclaration ';'
		| /* empty */
		;

/* 10.1. Formal parameters */

FormalParameters
		: '(' FPSection_list_opt ')' ':' qualident
		| '(' FPSection_list_opt ')'
		;

FPSection_list_opt
		: FPSection_list
		| /* empty */
		;

FPSection_list
		: FPSection_list ';' FPSection
		| FPSection
		;

FPSection
		: VAR IdentList ':' FormalType
		|     IdentList ':' FormalType
		;

FormalType
		: ARRAY OF qualident
		| qualident
		;

/* 11. Modules */

ModuleDeclaration
		: MODULE IDENT priority_opt ';'
			import_list_opt
			export_opt
		  block IDENT
		;

priority_opt
		: '[' ConstExpression ']'
		| /* empty */
		;

import_list_opt
		: import_list_opt import
		| /* empty */
		;

export_opt
		: EXPORT QUALIFIED IdentList ';'
		| EXPORT IdentList ';'
		| /* empty */
		;

import
		: FROM IDENT IMPORT IdentList ';'
		|            IMPORT IdentList ';'
		;

/* 14. Compilation Units */

DefinitionModule
		: DEFINITION MODULE IDENT ';'
			import_list_opt
			export_opt
			definition_list_opt
		  END IDENT '.'
		;

definition_list_opt
		: definition_list_opt definition
		| /* empty */
		;

definition
		: CONST ConstantDeclaration_list_opt
		| TYPE opaque_type_list_opt
		| VAR VariableDeclaration_list_opt
		| ProcedureHeading ';'
		| DefinitionModule ';'
		;

opaque_type_list_opt
		: opaque_type_list_opt opaque_type
		| /* empty */
		;

opaque_type
		: IDENT '=' type ';'
		| IDENT ';'
		;

ProgramModule
		: MODULE IDENT priority_opt ';'
			import_list_opt
		  block IDENT
		;

%%

static AVL_TREE db;

struct module *mod_find(char *name)
{
	if (!db) {
		db = new_stravl_tree(strcmp);
	}
	return avl_tree_get(db, name);
}

struct module *mod_put(struct module *prev)
{
	struct module *old = mod_find(prev->name);
	avl_tree_put(db, prev->name, prev);
	return old;
}

int yyerror(char *msg)
{
	printf(F("Error: %s\n"), msg);
	return 0;
}
