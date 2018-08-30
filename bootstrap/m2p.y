%{ 
/* m2p.y -- parser for MODULA-2.
 * Date: Tue Aug 21 08:10:26 EEST 2018
 * Based on the MODULA-2 report by N. Wirth, 1980.
 * See: https://doi.org/10.3929/ethz-a-000189918 (1980)
 * See: https://doi.org/10.3929/ethz-a-000153014 (1978)
 */

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <stravl.h>

#include "m2p.h"

#define QUOTE(x) "\033[37m<" x "\033[37m>"
#define LEFT(nt) QUOTE(#nt)
#define TERMIN(t) " \033[34m" t
#define NONTERM(s) " "QUOTE("\033[32m" #s)
#define SYMBOL(op) " \033[31m'" op "'"
#define KEYWORD(k) " \033[37m" #k
#define EMPTY " \033[34m/* EMPTY */"

#define RULE(lft, rgt, ...) do{ \
			printf(F("\033[37mR-%03d: "\
                "\033[37m<\033[36m"#lft"\033[37m>"\
                "\033[33m ::=" rgt "\033[33m.\033[m\n"),\
                yyn,##__VA_ARGS__); \
		}while(0)
%}

%token <string> AND ARRAY TBEGIN BY CASE CONST DEFINITION DIV DO ELSE ELSIF
%token <string> END EXIT EXPORT FOR FROM IF IMPLEMENTATION IMPORT IN LOOP
%token <string> MOD MODULE NOT OF OR POINTER PROCEDURE QUALIFIED RECORD
%token <string> REPEAT TRETURN SET THEN TO TYPE UNTIL VAR WHILE WITH

%token <string> ASSIGN LE GE NE RANGE
%type  <string> '+' '-' '*' '/' '&' '.' ',' ';' '{' '}' '[' ']' '(' ')'
%type  <string> '^' '=' '#' '<' '>' ':' '|'

%token <integer> INTEGER CHARLIT
%token <string> STRING IDENT MOD_IDENT
%token <real> REAL

%type  <nonterm> CompilationUnit qualident qualifier ConstantDeclaration ConstExpression
%type  <nonterm> relation SimpleConstExpr ConstTerm_list add_op_opt AddOperator
%type  <nonterm> ConstTerm MulOperator ConstFactor set element_list_opt element_list
%type  <nonterm> element TypeDeclaration type SimpleType enumeration IdentList
%type  <nonterm> SubrangeType ArrayType SimpleType_list RecordType FieldListSequence
%type  <nonterm> FieldList case_ident variant_list ELSE_FieldListSequence variant
%type  <nonterm> CaseLabelList CaseLabels SetType PointerType ProcedureType
%type  <nonterm> FormalTypeList paren_formal_parameter_type_list_opt
%type  <nonterm> formal_parameter_type_list_opt formal_parameter_type_list
%type  <nonterm> formal_parameter_type VariableDeclaration designator ExpList
%type  <nonterm> expression SimpleExpression term factor ActualParameters statement
%type  <nonterm> assignment ProcedureCall StatementSequence IfStatement
%type  <nonterm> elsif_seq else_opt CaseStatement case_list case WhileStatement
%type  <nonterm> RepeatStatement ForStatement by_opt LoopStatement WithStatement
%type  <nonterm> ProcedureDeclaration ProcedureHeading FormalParameters_opt block
%type  <nonterm> declaration_list_opt BEGIN_StatementSequence_opt declaration
%type  <nonterm> ConstantDeclaration_list_opt TypeDeclaration_list_opt
%type  <nonterm> VariableDeclaration_list_opt FormalParameters FPSection_list_opt
%type  <nonterm> FPSection_list FPSection FormalType ModuleDeclaration priority_opt
%type  <nonterm> import_list_opt export_opt import DefinitionModule definition_list_opt
%type  <nonterm> definition opaque_type_list_opt opaque_type ProgramModule
 
/* this token is returned when an error is detected in the
 * scanner. */

%union {
	const char 	 	   *string;
	int				 	integer;
	double			 	real;
	union tree_node		nonterm;
}

%% 

CompilationUnit
		: DefinitionModule '.' {
			RULE(CompilationUnit, NONTERM(DefinitionModule) SYMBOL("."));
            $$ = alloc_NONLEAF(CL_CompilationUnit, 1, 2, $1, alloc_SYMBOL('.', $2));
		}
		| IMPLEMENTATION ProgramModule '.' {
			RULE(CompilationUnit, KEYWORD(IMPLEMENTATION) NONTERM(ProgramModule) SYMBOL("."));
            $$ = alloc_NONLEAF(CL_CompilationUnit, 2, 3, alloc_SYMBOL(IMPLEMENTATION, $1), $2, alloc_SYMBOL('.', $3));
		}
		| ProgramModule '.' {
			RULE(CompilationUnit, NONTERM(ProgramModule) SYMBOL("."));
            $$ = alloc_NONLEAF(CL_CompilationUnit, 3, 2, $1, alloc_SYMBOL('.', $2));
		}
		;

qualident
		: qualifier '.' IDENT {
			RULE(qualident, NONTERM(qualifier) SYMBOL(".") TERMIN("IDENT:%s"), $3);
			$$ = alloc_NONLEAF(CL_qualident, 4, 3, $1, alloc_SYMBOL('.', $2), alloc_IDENT($3));
		}
		| IDENT {
			RULE(qualident, TERMIN("IDENT:%s"), $1);
			$$ = alloc_NONLEAF(CL_qualident, 5, 1, alloc_IDENT($1));
		}
		;

qualifier
		: qualifier '.' MOD_IDENT {
			RULE(qualifier, NONTERM(qualifier) SYMBOL(".") TERMIN("MOD_IDENT"));
			$$ = alloc_NONLEAF(CL_qualifier, 6, 3, $1, alloc_SYMBOL('.', $2), alloc_MOD_IDENT($3));
		}
		| MOD_IDENT {
			RULE(qualifier, TERMIN("MOD_IDENT"));
			$$ = alloc_NONLEAF(CL_qualifier, 7, 1, alloc_MOD_IDENT($1));
		}
		;

/* 5. Constant declarations */

ConstantDeclaration
		: IDENT '=' ConstExpression {
			RULE(ConstantDeclaration, TERMIN("IDENT:%s") SYMBOL("=") NONTERM(ConstExpression), $1);
			//$$ = alloc_node(ConstantDeclaration, 3, alloc_leaf(IDENT, $1), alloc_leaf('=', $2), $3);
		}
		;

ConstExpression
		: SimpleConstExpr relation SimpleConstExpr {
			RULE(ConstExpression, NONTERM(SimpleConstExpr) NONTERM(relation) NONTERM(SimpleConstExpr));
		}
		| SimpleConstExpr {
			RULE(ConstExpression, NONTERM(SimpleConstExpr));
		}
		;

relation
		: '=' {
			RULE(relation, SYMBOL("="));
			//$$ = alloc_node(relation, 1, alloc_leaf('=', $1));
		}
		| '#' {
			RULE(relation, SYMBOL("#"));
		}
		| NE {
			RULE(relation, SYMBOL("<>"));
		}
		| '<' {
			RULE(relation, SYMBOL("<"));
		}
		| LE {
			RULE(relation, SYMBOL("<="));
		}
		| '>' {
			RULE(relation, SYMBOL(">"));
		}
		| GE {
			RULE(relation, SYMBOL(">="));
		}
		| IN {
			RULE(relation, KEYWORD(IN));
		}
		;

SimpleConstExpr
		: ConstTerm_list {
			RULE(SimpleConstExpr, NONTERM(ConstTerm_list));
		}
		;

ConstTerm_list
		: ConstTerm_list AddOperator ConstTerm {
			RULE(ConstTerm_list, NONTERM(ConstTerm_list) NONTERM(AddOperator) NONTERM(ConstTerm));
		}
		| add_op_opt ConstTerm {
			RULE(ConstTerm_list, NONTERM(add_op_opt) NONTERM(ConstTerm));
		}
		;

add_op_opt
		: '+' {
			RULE(add_op_opt, SYMBOL("+"));
		}
		| '-' {
			RULE(add_op_opt, SYMBOL("-"));
		}
		| /* empty */ {
			RULE(add_op_opt, EMPTY);
		}
		;

AddOperator
		: '+' {
			RULE(AddOperator, SYMBOL("+"));
		}
		| '-' {
			RULE(AddOperator, SYMBOL("-"));
		}
		| OR {
			RULE(AddOperator, KEYWORD(OR));
		}
		;

ConstTerm
		: ConstTerm MulOperator ConstFactor {
			RULE(ConstTerm, NONTERM(ConstTerm) NONTERM(MulOperator) NONTERM(ConstFactor));
		}
		| ConstFactor {
			RULE(ConstTerm, NONTERM(ConstFactor));
		}
		;

MulOperator
		: '*' {
			RULE(MulOperator, SYMBOL("*"));
		}
		| '/' {
			RULE(MulOperator, SYMBOL("/"));
		}
		| DIV {
			RULE(MulOperator, KEYWORD(DIV));
		}
		| MOD {
			RULE(MulOperator, KEYWORD(MOD));
		}
		| AND {
			RULE(MulOperator, KEYWORD(AND));
		}
		| '&' {
			RULE(MulOperator, SYMBOL("&"));
		}
		;

ConstFactor
		: qualident {
			RULE(ConstFactor, NONTERM(qualident));
			printf(F("UNIMPLEMENTED YET\n"));
		}
		| INTEGER {
			RULE(ConstFactor, TERMIN("INTEGER(%d)"), $1);
			printf(F("UNIMPLEMENTED YET\n"));
		}
		| REAL {
			RULE(ConstFactor, TERMIN("REAL(%lg)"), $1);
			printf(F("UNIMPLEMENTED YET\n"));
		}
		| STRING {
			RULE(ConstFactor, TERMIN("STRING(%s)"), $1);
			printf(F("UNIMPLEMENTED YET\n"));
		}
		| CHARLIT {
			RULE(ConstFactor, TERMIN("CHARLIT(\\%03d)"), $1);
			printf(F("UNIMPLEMENTED YET\n"));
		}
		| set {
			RULE(ConstFactor, NONTERM(set));
			printf(F("UNIMPLEMENTED YET\n"));
		}
		| '(' ConstExpression ')' {
			RULE(ConstFactor, SYMBOL("(") NONTERM(ConstExpression) SYMBOL(")"));
			printf(F("UNIMPLEMENTED YET\n"));
		}
		| NOT ConstFactor {
			RULE(ConstFactor, KEYWORD(NOT) NONTERM(ConstFactor));
			printf(F("UNIMPLEMENTED YET\n"));
		}
		;

set
		: qualident '{' element_list_opt '}' {
			RULE(set, NONTERM(qualident) SYMBOL("{") NONTERM(element_list_opt) SYMBOL("}"));
		}
		| '{' element_list_opt '}' {
			RULE(set, SYMBOL("{") NONTERM(element_list_opt) SYMBOL("}"));
		}
		;

element_list_opt
		: element_list {
			RULE(element_list_opt, NONTERM(element_list));
		}
		| /* empty */ {
			RULE(element_list_opt, EMPTY);
		}
		;

element_list
		: element_list ',' element {
			RULE(element_list, NONTERM(element_list) SYMBOL(",") NONTERM(element));
		}
		| element {
			RULE(element_list, NONTERM(element));
		}
		;

element
		: ConstExpression RANGE ConstExpression {
			RULE(element, NONTERM(ConstExpression) SYMBOL("..") NONTERM(ConstExpression));
		}
		| ConstExpression  {
			RULE(element, NONTERM(ConstExpression));
		}
		;


/* 6. Type declarations */

TypeDeclaration
		: IDENT '=' type {
			RULE(TypeDeclaration, TERMIN("IDENT:%s") SYMBOL("=") NONTERM(type), $1);
		}
		;

type
		: SimpleType {
			RULE(type, NONTERM(SimpleType));
		}
		| ArrayType {
			RULE(type, NONTERM(ArrayType));
		}
		| RecordType {
			RULE(type, NONTERM(RecordType));
		}
		| SetType {
			RULE(type, NONTERM(SetType));
		}
		| PointerType {
			RULE(type, NONTERM(PointerType));
		}
		| ProcedureType {
			RULE(type, NONTERM(ProcedureType));
		}
		;

SimpleType
		: qualident {
			RULE(SimpleType, NONTERM(qualident));
		}
		| enumeration {
			RULE(SimpleType, NONTERM(enumeration));
		}
		| SubrangeType {
			RULE(SimpleType, NONTERM(SubrangeType));
		}
		;

/* 6.2. Enumerations */

enumeration
		: '(' IdentList ')' {
			RULE(enumeration, SYMBOL("(") NONTERM(IdentList) SYMBOL(")"));
		}
		;

IdentList
		: IdentList ',' IDENT {
			RULE(IdentList, NONTERM(IdentList) SYMBOL(",") TERMIN("IDENT:%s"), $3);
		}
		| IDENT {
			RULE(IdentList, TERMIN("IDENT:%s"), $1);
		}
		;

/* 6.3. Subrange types */

SubrangeType
		: '[' ConstExpression RANGE ConstExpression ']' {
			RULE(SubrangeType, SYMBOL("[") NONTERM(ConstExpression) SYMBOL("..") NONTERM(ConstExpression));
		}
		;

/* 6.4 Array types */

ArrayType
		: ARRAY SimpleType_list OF type {
			RULE(ArrayType, KEYWORD(ARRAY) NONTERM(SimpleType_list) KEYWORD(OF) NONTERM(type));
		}
		;

SimpleType_list
		: SimpleType_list ',' SimpleType {
			RULE(SimpleType_list, NONTERM(SimpleType_list) SYMBOL(",") NONTERM(SimpleType));
		}
		| SimpleType {
			RULE(SimpleType_list, NONTERM(SimpleType));
		}
		;

/* 6.5. Record types */

RecordType
		: RECORD
			FieldListSequence
		  END {
			RULE(RECORD, KEYWORD(RECORD) NONTERM(FieldListSequence) KEYWORD(END));
		}
		;

FieldListSequence
		: FieldListSequence ';' FieldList {
			RULE(FieldListSequence, NONTERM(FieldListSequence) SYMBOL(";") NONTERM(FieldList));
		}
		| FieldList {
			RULE(FieldListSequence, NONTERM(FieldList));
		}
		;

FieldList
		: IdentList ':' type {
			RULE(FieldList, NONTERM(IdentList) SYMBOL(":") NONTERM(type));
		}
		| CASE case_ident OF
				variant_list
				ELSE_FieldListSequence
		  END {
			RULE(FieldList, KEYWORD(CASE) NONTERM(case_ident) KEYWORD(OF)
			NONTERM(variant_list) NONTERM(ELSE_FieldListSequence) KEYWORD(END));
		}
		| /* empty */ {
			RULE(FieldList, EMPTY);
		}
		;

case_ident
		: IDENT ':' qualident  {
			RULE(case_ident, TERMIN("IDENT:%s") SYMBOL(":") NONTERM(qualident), $1);
		}
		| 			qualident {
			RULE(case_ident, NONTERM(qualident));
		}
		;

variant_list
		: variant_list '|' variant {
			RULE(variant_list, NONTERM(variant_list) SYMBOL("|") NONTERM(variant));
		}
		| variant {
			RULE(variant_list, NONTERM(variant));
		}
		;

ELSE_FieldListSequence
		: ELSE FieldListSequence {
			RULE(ELSE_FieldListSequence, KEYWORD(ELSE) NONTERM(FieldListSequence));
		}
		| /* empty */ {
			RULE(ELSE_FieldListSequence, EMPTY);
		}
		;

variant
		: CaseLabelList ':' FieldListSequence {
			RULE(variant, NONTERM(CaseLabelList) SYMBOL(":") NONTERM(FieldListSequence));
		}
		;

CaseLabelList
		: CaseLabelList ',' CaseLabels {
			RULE(CaseLabelList, NONTERM(CaseLabelList) SYMBOL(",") NONTERM(CaseLabels));
		}
		| CaseLabels {
			RULE(CaseLabelList, NONTERM(CaseLabels));
		}
		;

CaseLabels
		: ConstExpression RANGE ConstExpression {
			RULE(CaseLabels, NONTERM(ConstExpression) SYMBOL("..") NONTERM(ConstExpression));
		}
		| ConstExpression {
			RULE(CaseLabels, NONTERM(ConstExpression));
		}
		;

/* 6.6. Set types */

SetType
		: SET OF SimpleType {
			RULE(SetType, KEYWORD(SET) KEYWORD(OF) NONTERM(SimpleType));
		}
		;

/* 6.7. Pointer types */

PointerType
		: POINTER TO type {
			RULE(PointerType, KEYWORD(POINTER) KEYWORD(TO) NONTERM(type));
		}
		;

/* 6.8 Procedure types */

ProcedureType
		: PROCEDURE FormalTypeList {
			RULE(ProcedureType, KEYWORD(PROCEDURE) NONTERM(FormalTypeList));
		}
		| PROCEDURE {
			RULE(ProcedureType, KEYWORD(PROCEDURE));
		}
		;

FormalTypeList
		: paren_formal_parameter_type_list_opt ':' qualident {
			RULE(FormalTypeList, NONTERM(paren_formal_parameter_type_list_opt)
				SYMBOL(":") NONTERM(qualident));
		}
		| paren_formal_parameter_type_list_opt {
			RULE(FormalTypeList, NONTERM(paren_formal_parameter_type_list_opt));
		}
		;

paren_formal_parameter_type_list_opt
		: '(' formal_parameter_type_list_opt ')' {
			RULE(paren_formal_parameter_type_list_opt, SYMBOL("(")
				NONTERM(formal_parameter_type_list_opt) SYMBOL(")"));
		}
		;

formal_parameter_type_list_opt
		: formal_parameter_type_list {
			RULE(formal_parameter_type_list_opt,
				NONTERM(formal_parameter_type_list_opt));
		}
		| /* EMPTY */ {
			RULE(formal_parameter_type_list_opt, EMPTY);
		}
		;

formal_parameter_type_list
		: formal_parameter_type_list ',' formal_parameter_type {
			RULE(formal_parameter_type_list, NONTERM(formal_parameter_type_list)
				SYMBOL(",") NONTERM(formal_parameter_type));
		}
		| formal_parameter_type {
			RULE(formal_parameter_type_list, NONTERM(formal_parameter_type));
		}
		;

formal_parameter_type
		: VAR FormalType {
			RULE(formal_parameter_type, KEYWORD(VAR) NONTERM(FormalType));
		}
		| FormalType {
			RULE(formal_parameter_type, NONTERM(FormalType));
		}
		;

VariableDeclaration
		: IdentList ':' type {
			RULE(VariableDeclaration, NONTERM(IdentList) SYMBOL(":") NONTERM(type));
		}
		;

/* 8. Expressions */
/* 8.1. Operands */

designator
		: designator '.' IDENT {
			RULE(designator, NONTERM(designator) SYMBOL(".") TERMIN("IDENT:%s"), $3);
		}
		| designator '[' ExpList ']' {
			RULE(designator, NONTERM(designator) SYMBOL("[") NONTERM(ExpList) SYMBOL("]"));
		}
		| designator '^' {
			RULE(designator, NONTERM(designator) SYMBOL("^"));
		}
		| qualident {
			RULE(designator, NONTERM(qualident));
		}
		;

ExpList
		: ExpList ',' expression {
			RULE(ExpList, NONTERM(ExpList) SYMBOL(",") NONTERM(expression));
		}
		| expression {
			RULE(ExpList, NONTERM(expression));
		}
		;

/* 8.2 Operators */

expression
		: SimpleExpression relation SimpleExpression {
			RULE(expression, NONTERM(SimpleExpression)
				NONTERM(relation) NONTERM(SimpleExpression));
		}
		| SimpleExpression {
			RULE(expression, NONTERM(SimpleExpression));
		}
		;

SimpleExpression
		: SimpleExpression AddOperator term {
			RULE(SimpleExpression, NONTERM(SimpleExpression) NONTERM(AddOperator) NONTERM(term));
		}
		| add_op_opt term {
			RULE(SimpleExpression, NONTERM(add_op_opt) NONTERM(term));
		}
		;

term
		: term MulOperator factor {
			RULE(term, NONTERM(term) NONTERM(MulOperator) NONTERM(factor));
		}
		| factor {
			RULE(term, NONTERM(factor));
		}
		;

factor
		: INTEGER {
			RULE( factor, TERMIN("INTEGER(%d)"), $1);
		}
		| REAL {
			RULE(factor, TERMIN("REAL(%lg)"), $1);
		}
		| STRING {
			RULE(factor, TERMIN("STRING(%s)"), $1);
		}
		| CHARLIT {
			RULE(factor, TERMIN("CHARLIT(\\%03o)"), $1);
		}
		| set {
			RULE(factor, NONTERM(set));
		}
		| designator ActualParameters {
			RULE(factor, NONTERM(designator) NONTERM(ActualParameters));
		}
		| designator {
			RULE(factor, NONTERM(designator));
		}
		| '(' expression ')' {
			RULE(factor, SYMBOL("(") NONTERM(expression) SYMBOL(")"));
		}
		| NOT factor {
			RULE(factor, KEYWORD(NOT) NONTERM(factor));
		}
		;

ActualParameters
		: '(' ExpList ')' {
			RULE(ActualParameters, SYMBOL("(") NONTERM(ExpList) SYMBOL(")"));
		}
		| '(' ')' {
			RULE(ActualParameters, SYMBOL("(") SYMBOL(")"));
		}
		;

/* 9. Statements */

statement
		: assignment {
			RULE(statement, NONTERM(assignment));
		}
		| ProcedureCall {
			RULE(statement, NONTERM(ProcedureCall));
		}
		| IfStatement {
			RULE(statement, NONTERM(IfStatement));
		}
		| CaseStatement {
			RULE(statement, NONTERM(CaseStatement));
		}
		| WhileStatement {
			RULE(statement, NONTERM(WhileStatement));
		}
		| RepeatStatement {
			RULE(statement, NONTERM(RepeatStatement));
		}
		| LoopStatement {
			RULE(statement, NONTERM(LoopStatement));
		}
		| ForStatement {
			RULE(statement, NONTERM(ForStatement));
		}
		| WithStatement {
			RULE(statement, NONTERM(WithStatement));
		}
		| EXIT {
			RULE(statement, KEYWORD(EXIT));
		}
		| TRETURN expression {
			RULE(statement, KEYWORD(RETURN)NONTERM(expression));
		}
		| TRETURN {
			RULE(statement, KEYWORD(RETURN));
		}
		| /* empty */ {
			RULE(statement, EMPTY);
		}
		;

/* 9.1. Assignments */

assignment
		: designator ASSIGN expression {
			RULE(assignment, NONTERM(designator) SYMBOL(":=") NONTERM(expression));
		}
		;

/* 9.2. Procedure calls */

ProcedureCall
		: designator ActualParameters {
			RULE(ProcedureCall, NONTERM(designator) NONTERM(ActualParameters));
		}
		| designator {
			RULE(ProcedureCall, NONTERM(designator));
		}
		;

/* 9.3. Statement sequences */

StatementSequence
		: StatementSequence ';' statement {
			RULE(StatementSequence, NONTERM(StatementSequence) SYMBOL(";") NONTERM(statement));
		}
		| statement {
			RULE(StatementSequence, NONTERM(statement));
		}
		;

/* 9.4. If statement */

IfStatement
		: IF expression THEN
			StatementSequence
		  elsif_seq
		  else_opt
		  END {
			RULE(IfStatement, KEYWORD(IF) NONTERM(expression) KEYWORD(THEN)
				NONTERM(StatementSequence) NONTERM(elsif_seq) NONTERM(else_opt)
				KEYWORD(END));
		}
		;

elsif_seq
		: elsif_seq ELSIF expression THEN StatementSequence {
			RULE(elsif_seq, NONTERM(elsif_seq) KEYWORD(ELSIF)
				NONTERM(expression) KEYWORD(THEN) NONTERM(StatementSequence));
		}
		| /* EMPTY */ {
			RULE(elsif_seq, EMPTY);
		}
		;

else_opt
		: ELSE StatementSequence {
			RULE(else_opt, KEYWORD(ELSE) NONTERM(StatementSequence));
		}
		| /* EMPTY */ {
			RULE(else_opt, EMPTY);
		}
		;

/* 9.5. Case statements */

CaseStatement
		: CASE expression OF
			case_list
			else_opt
		  END {
			RULE(CaseStatement, KEYWORD(CASE) NONTERM(expression) KEYWORD(OF)
				NONTERM(case_list) NONTERM(else_opt) KEYWORD(END));
		}
		;

case_list
		: case_list '|' case {
			RULE(case_list, NONTERM(case_list) SYMBOL("|") NONTERM(case));
		}
		| case {
			RULE(case_list, NONTERM(case));
		}
		;

case
		: CaseLabelList ':' StatementSequence {
			RULE(case, NONTERM(CaseLabelList) SYMBOL(":") NONTERM(StatementSequence));
		}
		;

/* 9.6. While statements */

WhileStatement
		: WHILE expression DO
			StatementSequence
		  END {
			RULE(WhileStatement, KEYWORD(WHILE) NONTERM(expression) KEYWORD(DO)
				NONTERM(StatementSequence) KEYWORD(END));
		}
		;

/* 9.7. Repeat statements */

RepeatStatement
		: REPEAT
			StatementSequence
		  UNTIL expression {
			RULE(RepeatStatement, KEYWORD(REPEAT)
				NONTERM(StatementSequence)
				KEYWORD(UNTIL) NONTERM(expression));
		}
		;

/* 9.8. For statements */

ForStatement
		: FOR IDENT ASSIGN expression TO expression by_opt DO
			StatementSequence
		  END {
			RULE(ForStatement, KEYWORD(FOR) TERMIN("IDENT:%s") SYMBOL(":=")
				NONTERM(expression) KEYWORD(TO) NONTERM(expression)
				NONTERM(by_opt) KEYWORD(DO) NONTERM(StatementSequence)
				KEYWORD(END), $2);
		}
		;

by_opt
		: BY ConstExpression {
			RULE(by_opt, KEYWORD(BY) NONTERM(ConstExpression));
		}
		| /* empty */ {
			RULE(by_opt, EMPTY);
		}
		;

/* 9.9. Loop statements */

LoopStatement
		: LOOP
			StatementSequence
		  END {
			RULE(LoopStatement, KEYWORD(LOOP) NONTERM(StatementSequence)
				KEYWORD(END));
		}
		;

/* 9.10. With statements */

WithStatement
		: WITH designator DO StatementSequence END {
			RULE(WithStatement, KEYWORD(WITH) NONTERM(designator)
				KEYWORD(DO) NONTERM(StatementSequence) KEYWORD(END));
		}
		;

/* 10. Procedure declarations */

ProcedureDeclaration
		: ProcedureHeading ';' block IDENT {
            RULE(ProcedureDeclaration, NONTERM(ProcedureHeading)
                SYMBOL(";") NONTERM(block) TERMIN("IDENT:%s"), $4);
		}
		;

ProcedureHeading
		: PROCEDURE IDENT FormalParameters_opt {
			RULE(ProcedureHeading, KEYWORD(PROCEDURE) TERMIN("IDENT:%s")
				NONTERM(FormalParameters_opt), $2);
		}
		;

FormalParameters_opt
		: FormalParameters {
			RULE(FormalParameters_opt, NONTERM(FormalParameters));
		}
		| /* empty */ {
			RULE(FormalParameters_opt, EMPTY);
		}
		;

block
		: declaration_list_opt
		  BEGIN_StatementSequence_opt
		  END {
			RULE(block, NONTERM(declaration_list_opt)
				NONTERM(BEGIN_StatementSequence_opt) KEYWORD(END));
		}
		;

declaration_list_opt
		: declaration_list_opt declaration {
			RULE(declaration_list_opt, NONTERM(declaration_list_opt)
				NONTERM(declaration));
		}
		| /* empty */ {
			RULE(declaration_list_opt, EMPTY);
            /* TODO: Creation of symbol table from the in-scope one.
             * This has to be done in several places.  To be continued.
			 * Here we define a new symbol table (struct symtab *) and 
			 * we initialize it in case we don't have a parent (active_symtab
			 * is null) with the pervasive identifiers, as this means we are
			 * in a top level module (level 0) and pervasive identifiers
			 * cannot be redefined (redefinition is forbidden, you redefine
			 * things by nesting on procedure blocks ---aka hidding---, as
			 * specified in spec document)
			 * We need two stacks to manage module nesting, as we need to
			 * restore MODULE's nesting, but a module sym tab has no
             */
		}
		;

BEGIN_StatementSequence_opt
		: TBEGIN StatementSequence {
			RULE(BEGIN_StatementSequence_opt, KEYWORD(BEGIN)
				NONTERM(StatementSequence));
		}
		| /* empty */ {
			RULE(BEGIN_StatementSequence_opt, EMPTY);
		}
		;

declaration
		: CONST ConstantDeclaration_list_opt {
			RULE(declaration, KEYWORD(CONST) NONTERM(ConstantDeclaration_list_opt));
		}
		| TYPE TypeDeclaration_list_opt {
			RULE(declaration, KEYWORD(TYPE) NONTERM(TypeDeclaration_list_opt));
		}
		| VAR VariableDeclaration_list_opt {
			RULE(declaration, KEYWORD(VAR) NONTERM(VariableDeclaration_list_opt));
		}
		| ProcedureDeclaration ';' {
			RULE(declaration, NONTERM(ProcedureDeclaration) SYMBOL(";"));
		}
		| ModuleDeclaration ';' {
			RULE(declaration, NONTERM(ModuleDeclaration) SYMBOL(";"));
		}
		;

ConstantDeclaration_list_opt
		: ConstantDeclaration_list_opt ConstantDeclaration ';' {
			RULE(ConstantDeclaration_list_opt, NONTERM(ConstantDeclaration_list_opt)
				NONTERM(ConstantDeclaration) SYMBOL(";"));
		}
		| /* empty */ {
			RULE(ConstantDeclaration_list_opt, EMPTY);
		}
		;

TypeDeclaration_list_opt
		: TypeDeclaration_list_opt TypeDeclaration ';' {
			RULE(TypeDeclaration_list_opt, NONTERM(TypeDeclaration_list_opt)
				NONTERM(TypeDeclaration) SYMBOL(";"));
		}
		| /* empty */ {
			RULE(TypeDeclaration_list_opt, EMPTY);
		}
		;

VariableDeclaration_list_opt
		: VariableDeclaration_list_opt VariableDeclaration ';' {
			RULE(VariableDeclaration_list_opt, NONTERM(VariableDeclaration_list_opt)
				NONTERM(VariableDeclaration) SYMBOL(";"));
		}
		| /* empty */ {
			RULE(VariableDeclaration_list_opt, EMPTY);
		}
		;

/* 10.1. Formal parameters */

FormalParameters
		: '(' FPSection_list_opt ')' ':' qualident {
			RULE(FormalParameters, SYMBOL("(") NONTERM(FPSection_list_opt)
				SYMBOL(")") SYMBOL(":") NONTERM(qualident));
		}
		| '(' FPSection_list_opt ')' {
			RULE(FormalParameters, SYMBOL("(") NONTERM(FPSection_list_opt)
				SYMBOL(")"));
		}
		;

FPSection_list_opt
		: FPSection_list {
			RULE(FPSection_list_opt, NONTERM(FPSection_list));
		}
		| /* empty */ {
			RULE(FPSection_list_opt, EMPTY);
		}
		;

FPSection_list
		: FPSection_list ';' FPSection {
			RULE(FPSection_list, NONTERM(FPSection_list) SYMBOL(";") NONTERM(FPSection));
		}
		| FPSection {
			RULE(FPSection_list, NONTERM(FPSection));
		}
		;

FPSection
		: VAR IdentList ':' FormalType {
			RULE(FPSection, KEYWORD(VAR) NONTERM(IdentList) SYMBOL(":") NONTERM(FormalType));
		}
		|     IdentList ':' FormalType {
			RULE(FPSection, NONTERM(IdentList) SYMBOL(":") NONTERM(FormalType));
		}
		;

FormalType
		: ARRAY OF qualident {
			RULE(FormalType, KEYWORD(ARRAY) KEYWORD(OF) NONTERM(qualident));
		}
		| qualident {
			RULE(FormalType, NONTERM(qualident));
		}
		;

/* 11. Modules */

ModuleDeclaration
		: MODULE IDENT priority_opt ';'
			import_list_opt
			export_opt
		  block IDENT {
			RULE(ModuleDeclaration, KEYWORD(MODULE) TERMIN("IDENT:%s") NONTERM(priority_opt) SYMBOL(";")
				NONTERM(import_list_opt) NONTERM(export_opt) NONTERM(block) TERMIN("IDENT:%s"), $2, $8);
		}
		;

priority_opt
		: '[' ConstExpression ']' {
			RULE(priority_opt, SYMBOL("[") NONTERM(ConstExpression) SYMBOL("]"));
		}
		| /* empty */ {
			RULE(priority_opt, EMPTY);
		}
		;

import_list_opt
		: import_list_opt import {
			RULE(import_list_opt, NONTERM(import_list_opt) NONTERM(import));
		}
		| /* empty */ {
			RULE(import_list_opt, EMPTY);
		}
		;

export_opt
		: EXPORT QUALIFIED IdentList ';' {
			RULE(export_opt, KEYWORD(EXPORT) KEYWORD(QUALIFIED) NONTERM(IdentList) SYMBOL(";"));
		}
		| EXPORT IdentList ';' {
			RULE(export_opt, KEYWORD(EXPORT) NONTERM(IdentList) SYMBOL(";"));
		}
		| /* empty */ {
			RULE(export_opt, EMPTY);
		}
		;

import
		: FROM IDENT IMPORT IdentList ';' {
			RULE(import, KEYWORD(FROM) TERMIN("IDENT:%s") KEYWORD(IMPORT)
				NONTERM(IdentList) SYMBOL(";"), $2);
		}
		|            IMPORT IdentList ';' {
			RULE(import, KEYWORD(IMPORT) NONTERM(IdentList) SYMBOL(";"));
		}
		;

/* 14. Compilation Units */

DefinitionModule
		: DEFINITION MODULE IDENT ';'
			import_list_opt
			export_opt
			definition_list_opt
		  END IDENT {
			RULE(DefinitionModule, KEYWORD(DEFINITION) KEYWORD(MODULE) TERMIN("IDENT:%s") SYMBOL(";")
				NONTERM(import_list_opt) NONTERM(export_opt) NONTERM(definition_list_opt)
				KEYWORD(END) TERMIN("IDENT:%s"), $3, $9);
			if ($3 != $9) {
				ERROR("Module identifier at header(%s) doesn't match at end(%s)\n", $3, $9);
			}
		}
		;

definition_list_opt
		: definition_list_opt definition {
			RULE(definition_list_opt, NONTERM(definition_list_opt) NONTERM(definition));
		}
		| /* empty */ {
			RULE(definition_list_opt, EMPTY);
		}
		;

definition
		: CONST ConstantDeclaration_list_opt {
			RULE(definition, KEYWORD(CONST) NONTERM(ConstantDeclaration_list_opt));
		}
		| TYPE opaque_type_list_opt {
			RULE(definition, KEYWORD(TYPE) NONTERM(opaque_type_list_opt));
		}
		| VAR VariableDeclaration_list_opt {
			RULE(definition, KEYWORD(VAR) NONTERM(VariableDeclaration_list_opt));
		}
		| ProcedureHeading ';' {
			RULE(definition, NONTERM(ProcedureHeading) SYMBOL(";"));
		}
		;

opaque_type_list_opt
		: opaque_type_list_opt opaque_type {
			RULE(opaque_type_list_opt, NONTERM(opaque_type_list_opt) NONTERM(opaque_type));
		}
		| /* empty */ {
			RULE(opaque_type_list_opt, EMPTY);
		}
		;

opaque_type
		: IDENT '=' type ';' {
			RULE(opaque_type, TERMIN("IDENT:%s") SYMBOL("=") NONTERM(type) SYMBOL(";"), $1);
		}
		| IDENT ';' {
			RULE(opaque_type, TERMIN("IDENT:%s") SYMBOL(";"), $1);
		}
		;

ProgramModule
		: MODULE IDENT priority_opt ';'
			import_list_opt
		  block IDENT {
			RULE(ProgramModule, KEYWORD(MODULE) TERMIN("IDENT:%s") NONTERM(priority_opt) SYMBOL(";")
				NONTERM(import_list_opt) NONTERM(block) TERMIN("IDENT:%s"), $2, $7);
			if ($2 != $7) {
				ERROR("Module identifier at header(%s) doesn't match at end(%s)\n", $2, $7);
			}
		}
		;

%%

int yyerror(char *msg)
{
	printf(F("Error: %s\n"), msg);
	return 0;
}
