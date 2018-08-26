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

#define QUOTE(x) "\033[37m<" x "\033[37m>"
#define LEFT(nt) QUOTE(#nt)
#define TERMIN(t) " \033[34m" t
#define NONTERM(s) " "QUOTE("\033[32m" #s)
#define SYMBOL(op) " \033[31m'" op "'"
#define KEYWORD(k) " \033[37m" #k
#define EMPTY " \033[34m/* EMPTY */"

#define RULE(maj,min,lft, rgt, ...) do{ \
			printf(F("\033[37mR-%02d.%02d: "\
                "\033[37m<\033[36m"#lft"\033[37m>"\
                "\033[33m ::=" rgt "\033[33m.\033[m\n"),\
                maj,min,##__VA_ARGS__); \
		}while(0)

%}

%token AND ARRAY TBEGIN BY CASE CONST DEFINITION DIV DO ELSE ELSIF
%token END EXIT EXPORT FOR FROM IF IMPLEMENTATION IMPORT IN LOOP
%token MOD MODULE NOT OF OR POINTER PROCEDURE QUALIFIED RECORD
%token REPEAT TRETURN SET THEN TO TYPE UNTIL VAR WHILE WITH

%token ASSIGN LE GE NE RANGE
%token <integer> INTEGER CHARLIT
%token <string> STRING IDENT QUAL_IDENT
%token <real> DOUBLE

%type <integer> relation add_op_opt AddOperator MulOperator

/* this token is returned when an error is detected in the
 * scanner. */
%token BAD_TOKEN

%union {
	int  integer;
	double real;
	const char *string;
}

%%

CompilationUnit
		: DefinitionModule '.' {
			RULE(1,0, CompilationUnit, NONTERM(DefinitionModule) SYMBOL("."));
		}
		| IMPLEMENTATION ProgramModule '.' {
			RULE(1,1, CompilationUnit, KEYWORD(IMPLEMENTATION) NONTERM(ProgramModule) SYMBOL("."));
		}
		| ProgramModule '.' {
			RULE(1,2, CompilationUnit, NONTERM(ProgramModule) SYMBOL("."));
		}
		;

qualident
		: qualifier '.' IDENT {
			RULE(2,0, qualident, NONTERM(qualifier) SYMBOL(".") TERMIN("IDENT:%s"), $3);
		}
		| IDENT {
			RULE(2,1,qualident, TERMIN("IDENT:%s"), $1);
		}
		;

qualifier
		: qualifier '.' QUAL_IDENT {
			RULE(3,0,qualifier, NONTERM(qualifier) SYMBOL(".") TERMIN("QUAL_IDENT"));
		}
		| QUAL_IDENT {
			RULE(3,1,qualifier, TERMIN("QUAL_IDENT"));
		}
		;

/* 5. Constant declarations */

ConstantDeclaration
		: IDENT '=' ConstExpression {
			RULE(4,0,ConstantDeclaration, TERMIN("IDENT:%s") SYMBOL("=") NONTERM(ConstExpression), $1);
		}
		;

ConstExpression
		: SimpleConstExpr relation SimpleConstExpr {
			RULE(5,0,ConstExpression, NONTERM(SimpleConstExpr) NONTERM(relation) NONTERM(SimpleConstExpr));
		}
		| SimpleConstExpr {
			RULE(5,1,ConstExpression, NONTERM(SimpleConstExpr));
		}
		;

relation
		: '=' {
			RULE(6,0,relation, SYMBOL("="));
			$$ = '=';
		}
		| '#' {
			RULE(6,1,relation, SYMBOL("#"));
			$$ = '#';
		}
		| NE {
			RULE(6,2,relation, SYMBOL("<>"));
			$$ = NE;
		}
		| '<' {
			RULE(6,3,relation, SYMBOL("<"));
			$$ = '<';
		}
		| LE {
			RULE(6,4,relation, SYMBOL("<="));
			$$ = LE;
		}
		| '>' {
			RULE(6,5,relation, SYMBOL(">"));
			$$ = '>';
		}
		| GE {
			RULE(6,6,relation, SYMBOL(">="));
			$$ = GE;
		}
		| IN {
			RULE(6,7,relation, KEYWORD(IN));
			$$ = IN;
		}
		;

SimpleConstExpr
		: ConstTerm_list {
			RULE(7,0,SimpleConstExpr, NONTERM(ConstTerm_list));
		}
		;

ConstTerm_list
		: ConstTerm_list AddOperator ConstTerm {
			RULE(8,0,ConstTerm_list, NONTERM(ConstTerm_list) NONTERM(AddOperator) NONTERM(ConstTerm));
		}
		| add_op_opt ConstTerm {
			RULE(8,1,ConstTerm_list, NONTERM(add_op_opt) NONTERM(ConstTerm));
		}
		;

add_op_opt
		: '+' {
			RULE(9,0,add_op_opt, SYMBOL("+"));
			$$ = '+';
		}
		| '-' {
			RULE(9,1,add_op_opt, SYMBOL("-"));
			$$ = '-';
		}
		| /* empty */ {
			RULE(9,2,add_op_opt, EMPTY);
			$$ = '+';
		}
		;

AddOperator
		: '+' {
			RULE(10,0,AddOperator, SYMBOL("+"));
			$$ = '+';
		}
		| '-' {
			RULE(10,1,AddOperator, SYMBOL("-"));
			$$ = '-';
		}
		| OR {
			RULE(10,2,AddOperator, KEYWORD(OR));
			$$ = OR;
		}
		;

ConstTerm
		: ConstTerm MulOperator ConstFactor {
			RULE(11,0,ConstTerm, NONTERM(ConstTerm) NONTERM(MulOperator) NONTERM(ConstFactor));
		}
		| ConstFactor {
			RULE(11,1,ConstTerm, NONTERM(ConstFactor));
		}
		;

MulOperator
		: '*' {
			RULE(12,0,MulOperator, SYMBOL("*"));
			$$ = '*';
		}
		| '/' {
			RULE(12,1,MulOperator, SYMBOL("/"));
			$$ = '/';
		}
		| DIV {
			RULE(12,2,MulOperator, KEYWORD(DIV));
			$$ = DIV;
		}
		| MOD {
			RULE(12,3,MulOperator, KEYWORD(MOD));
			$$ = MOD;
		}
		| AND {
			RULE(12,4,MulOperator, KEYWORD(AND));
			$$ = AND;
		}
		| '&' {
			RULE(12,5,MulOperator, SYMBOL("&"));
			$$ = '&';
		}
		;

ConstFactor
		: qualident {
			RULE(13,0,ConstFactor, NONTERM(qualident));
		}
		| INTEGER {
			RULE(13,1,ConstFactor, TERMIN("INTEGER(%d)"), $1);
		}
		| DOUBLE {
			RULE(13,2,ConstFactor, TERMIN("DOUBLE(%lg)"), $1);
		}
		| STRING {
			RULE(13,3,ConstFactor, TERMIN("STRING(%s)"), $1);
		}
		| CHARLIT {
			RULE(13,4,ConstFactor, TERMIN("CHARLIT(\\%03d)"), $1);
		}
		| set {
			RULE(13,5,ConstFactor, NONTERM(set));
		}
		| '(' ConstExpression ')' {
			RULE(13,6,ConstFactor, SYMBOL("(") NONTERM(ConstExpression) SYMBOL(")"));
		}
		| NOT ConstFactor {
			RULE(13,7,ConstFactor, KEYWORD(NOT) NONTERM(ConstFactor));
		}
		;

set
		: qualident '{' element_list_opt '}' {
			RULE(14,0,set, NONTERM(qualident) SYMBOL("{") NONTERM(element_list_opt) SYMBOL("}"));
		}
		| '{' element_list_opt '}' {
			RULE(14,1,set, SYMBOL("{") NONTERM(element_list_opt) SYMBOL("}"));
		}
		;

element_list_opt
		: element_list {
			RULE(15,0,element_list_opt, NONTERM(element_list));
		}
		| /* empty */ {
			RULE(15,1,element_list_opt, EMPTY);
		}
		;

element_list
		: element_list ',' element {
			RULE(16,0,element_list, NONTERM(element_list) SYMBOL(",") NONTERM(element));
		}
		| element {
			RULE(16,1,element_list, NONTERM(element));
		}
		;

element
		: ConstExpression RANGE ConstExpression {
			RULE(17,0,element, NONTERM(ConstExpression) SYMBOL("..") NONTERM(ConstExpression));
		}
		| ConstExpression  {
			RULE(17,1,element, NONTERM(ConstExpression));
		}
		;


/* 6. Type declarations */

TypeDeclaration
		: IDENT '=' type {
			RULE(18,0,TypeDeclaration, TERMIN("IDENT:%s") SYMBOL("=") NONTERM(type), $1);
		}
		;

type
		: SimpleType {
			RULE(19,0,type, NONTERM(SimpleType));
		}
		| ArrayType {
			RULE(19,1,type, NONTERM(ArrayType));
		}
		| RecordType {
			RULE(19,2,type, NONTERM(RecordType));
		}
		| SetType {
			RULE(19,3,type, NONTERM(SetType));
		}
		| PointerType {
			RULE(19,4,type, NONTERM(PointerType));
		}
		| ProcedureType {
			RULE(19,5,type, NONTERM(ProcedureType));
		}
		;

SimpleType
		: qualident {
			RULE(20,0,SimpleType, NONTERM(qualident));
		}
		| enumeration {
			RULE(20,1,SimpleType, NONTERM(enumeration));
		}
		| SubrangeType {
			RULE(20,2,SimpleType, NONTERM(SubrangeType));
		}
		;

/* 6.2. Enumerations */

enumeration
		: '(' IdentList ')' {
			RULE(21,0,enumeration, SYMBOL("(") NONTERM(IdentList) SYMBOL(")"));
		}
		;

IdentList
		: IdentList ',' IDENT {
			RULE(22,0,IdentList, NONTERM(IdentList) SYMBOL(",") TERMIN("IDENT:%s"), $3);
		}
		| IDENT {
			RULE(22,1,IdentList, TERMIN("IDENT:%s"), $1);
		}
		;

/* 6.3. Subrange types */

SubrangeType
		: '[' ConstExpression RANGE ConstExpression ']' {
			RULE(23,0,SubrangeType, SYMBOL("[") NONTERM(ConstExpression) SYMBOL("..") NONTERM(ConstExpression));
		}
		;

/* 6.4 Array types */

ArrayType
		: ARRAY SimpleType_list OF type {
			RULE(24,0,ArrayType, KEYWORD(ARRAY) NONTERM(SimpleType_list) KEYWORD(OF) NONTERM(type));
		}
		;

SimpleType_list
		: SimpleType_list ',' SimpleType {
			RULE(25,0,SimpleType_list, NONTERM(SimpleType_list) SYMBOL(",") NONTERM(SimpleType));
		}
		| SimpleType {
			RULE(25,1,SimpleType_list, NONTERM(SimpleType));
		}
		;

/* 6.5. Record types */

RecordType
		: RECORD
			FieldListSequence
		  END {
			RULE(26,0,RECORD, KEYWORD(RECORD) NONTERM(FieldListSequence) KEYWORD(END));
		}
		;

FieldListSequence
		: FieldListSequence ';' FieldList {
			RULE(27,0,FieldListSequence, NONTERM(FieldListSequence) SYMBOL(";") NONTERM(FieldList));
		}
		| FieldList {
			RULE(27,1,FieldListSequence, NONTERM(FieldList));
		}
		;

FieldList
		: IdentList ':' type {
			RULE(28,0,FieldList, NONTERM(IdentList) SYMBOL(":") NONTERM(type));
		}
		| CASE case_ident OF
				variant_list
				ELSE_FieldListSequence
		  END {
			RULE(28,1,FieldList, KEYWORD(CASE) NONTERM(case_ident) KEYWORD(OF)
			NONTERM(variant_list) NONTERM(ELSE_FieldListSequence) KEYWORD(END));
		}
		| /* empty */ {
			RULE(28,2,FieldList, EMPTY);
		}
		;

case_ident
		: IDENT ':' qualident  {
			RULE(29,0,case_ident, TERMIN("IDENT:%s") SYMBOL(":") NONTERM(qualident), $1);
		}
		| 			qualident {
			RULE(29,1,case_ident, NONTERM(qualident));
		}
		;

variant_list
		: variant_list '|' variant {
			RULE(30,0,variant_list, NONTERM(variant_list) SYMBOL("|") NONTERM(variant));
		}
		| variant {
			RULE(30,1,variant_list, NONTERM(variant));
		}
		;

ELSE_FieldListSequence
		: ELSE FieldListSequence {
			RULE(31,0,ELSE_FieldListSequence, KEYWORD(ELSE) NONTERM(FieldListSequence));
		}
		| /* empty */ {
			RULE(31,1,ELSE_FieldListSequence, EMPTY);
		}
		;

variant
		: CaseLabelList ':' FieldListSequence {
			RULE(32,0,variant, NONTERM(CaseLabelList) SYMBOL(":") NONTERM(FieldListSequence));
		}
		;

CaseLabelList
		: CaseLabelList ',' CaseLabels {
			RULE(33,0,CaseLabelList, NONTERM(CaseLabelList) SYMBOL(",") NONTERM(CaseLabels));
		}
		| CaseLabels {
			RULE(33,1,CaseLabelList, NONTERM(CaseLabels));
		}
		;

CaseLabels
		: ConstExpression RANGE ConstExpression {
			RULE(34,0,CaseLabels, NONTERM(ConstExpression) SYMBOL("..") NONTERM(ConstExpression));
		}
		| ConstExpression {
			RULE(34,1,CaseLabels, NONTERM(ConstExpression));
		}
		;

/* 6.6. Set types */

SetType
		: SET OF SimpleType {
			RULE(35,0,SetType, KEYWORD(SET) KEYWORD(OF) NONTERM(SimpleType));
		}
		;

/* 6.7. Pointer types */

PointerType
		: POINTER TO type {
			RULE(36,0,PointerType, KEYWORD(POINTER) KEYWORD(TO) NONTERM(type));
		}
		;

/* 6.8 Procedure types */

ProcedureType
		: PROCEDURE FormalTypeList {
			RULE(37,0,ProcedureType, KEYWORD(PROCEDURE) NONTERM(FormalTypeList));
		}
		| PROCEDURE {
			RULE(37,1,ProcedureType, KEYWORD(PROCEDURE));
		}
		;

FormalTypeList
		: paren_formal_parameter_type_list_opt ':' qualident {
			RULE(38,0,FormalTypeList, NONTERM(paren_formal_parameter_type_list_opt)
				SYMBOL(":") NONTERM(qualident));
		}
		| paren_formal_parameter_type_list_opt {
			RULE(38,1,FormalTypeList, NONTERM(paren_formal_parameter_type_list_opt));
		}
		;

paren_formal_parameter_type_list_opt
		: '(' formal_parameter_type_list_opt ')' {
			RULE(39,0,paren_formal_parameter_type_list_opt, SYMBOL("(")
				NONTERM(formal_parameter_type_list_opt) SYMBOL(")"));
		}
		;

formal_parameter_type_list_opt
		: formal_parameter_type_list {
			RULE(40,0,formal_parameter_type_list_opt,
				NONTERM(formal_parameter_type_list_opt));
		}
		| /* EMPTY */ {
			RULE(40,1,formal_parameter_type_list_opt, EMPTY);
		}
		;

formal_parameter_type_list
		: formal_parameter_type_list ',' formal_parameter_type {
			RULE(41,0,formal_parameter_type_list, NONTERM(formal_parameter_type_list)
				SYMBOL(",") NONTERM(formal_parameter_type));
		}
		| formal_parameter_type {
			RULE(41,1,formal_parameter_type_list, NONTERM(formal_parameter_type));
		}
		;

formal_parameter_type
		: VAR FormalType {
			RULE(42,0,formal_parameter_type, KEYWORD(VAR) NONTERM(FormalType));
		}
		| FormalType {
			RULE(42,1,formal_parameter_type, NONTERM(FormalType));
		}
		;

VariableDeclaration
		: IdentList ':' type {
			RULE(43,0,VariableDeclaration, NONTERM(IdentList) SYMBOL(":") NONTERM(type));
		}
		;

/* 8. Expressions */
/* 8.1. Operands */

designator
		: designator '.' IDENT {
			RULE(44,0,designator, NONTERM(designator) SYMBOL(".") TERMIN("IDENT:%s"), $3);
		}
		| designator '[' ExpList ']' {
			RULE(44,1,designator, NONTERM(designator) SYMBOL("[") NONTERM(ExpList) SYMBOL("]"));
		}
		| designator '^' {
			RULE(44,2,designator, NONTERM(designator) SYMBOL("^"));
		}
		| qualident {
			RULE(44,3,designator, NONTERM(qualident));
		}
		;

ExpList
		: ExpList ',' expression {
			RULE(45,0,ExpList, NONTERM(ExpList) SYMBOL(",") NONTERM(expression));
		}
		| expression {
			RULE(45,1,ExpList, NONTERM(expression));
		}
		;

/* 8.2 Operators */

expression
		: SimpleExpression relation SimpleExpression {
			RULE(46,0,expression, NONTERM(SimpleExpression)
				NONTERM(relation) NONTERM(SimpleExpression));
		}
		| SimpleExpression {
			RULE(46,1,expression, NONTERM(SimpleExpression));
		}
		;

SimpleExpression
		: SimpleExpression AddOperator term {
			RULE(47,0,SimpleExpression, NONTERM(SimpleExpression) NONTERM(AddOperator) NONTERM(term));
		}
		| add_op_opt term {
			RULE(47,1,SimpleExpression, NONTERM(add_op_opt) NONTERM(term));
		}
		;

term
		: term MulOperator factor {
			RULE(48,0,term, NONTERM(term) NONTERM(MulOperator) NONTERM(factor));
		}
		| factor {
			RULE(48,1,term, NONTERM(factor));
		}
		;

factor
		: INTEGER {
			RULE(49,0, factor, TERMIN("INTEGER(%d)"), $1);
		}
		| DOUBLE {
			RULE(49,1,factor, TERMIN("DOUBLE(%lg)"), $1);
		}
		| STRING {
			RULE(49,2,factor, TERMIN("STRING(%s)"), $1);
		}
		| CHARLIT {
			RULE(49,3,factor, TERMIN("CHARLIT(\\%03o)"), $1);
		}
		| set {
			RULE(49,4,factor, NONTERM(set));
		}
		| designator ActualParameters {
			RULE(49,5,factor, NONTERM(designator) NONTERM(ActualParameters));
		}
		| designator {
			RULE(49,6,factor, NONTERM(designator));
		}
		| '(' expression ')' {
			RULE(49,7,factor, SYMBOL("(") NONTERM(expression) SYMBOL(")"));
		}
		| NOT factor {
			RULE(49,8,factor, KEYWORD(NOT) NONTERM(factor));
		}
		;

ActualParameters
		: '(' ExpList ')' {
			RULE(50,0,ActualParameters, SYMBOL("(") NONTERM(ExpList) SYMBOL(")"));
		}
		| '(' ')' {
			RULE(50,1,ActualParameters, SYMBOL("(") SYMBOL(")"));
		}
		;

/* 9. Statements */

statement
		: assignment {
			RULE(51,0,statement, NONTERM(assignment));
		}
		| ProcedureCall {
			RULE(51,1,statement, NONTERM(ProcedureCall));
		}
		| IfStatement {
			RULE(51,2,statement, NONTERM(IfStatement));
		}
		| CaseStatement {
			RULE(51,3,statement, NONTERM(CaseStatement));
		}
		| WhileStatement {
			RULE(51,4,statement, NONTERM(WhileStatement));
		}
		| RepeatStatement {
			RULE(51,5,statement, NONTERM(RepeatStatement));
		}
		| LoopStatement {
			RULE(51,6,statement, NONTERM(LoopStatement));
		}
		| ForStatement {
			RULE(51,7,statement, NONTERM(ForStatement));
		}
		| WithStatement {
			RULE(51,8,statement, NONTERM(WithStatement));
		}
		| EXIT {
			RULE(51,9,statement, KEYWORD(EXIT));
		}
		| TRETURN expression {
			RULE(51,10,statement, KEYWORD(RETURN)NONTERM(expression));
		}
		| TRETURN {
			RULE(51,11,statement, KEYWORD(RETURN));
		}
		| /* empty */ {
			RULE(51,12,statement, EMPTY);
		}
		;

/* 9.1. Assignments */

assignment
		: designator ASSIGN expression {
			RULE(52,0,assignment, NONTERM(designator) SYMBOL(":=") NONTERM(expression));
		}
		;

/* 9.2. Procedure calls */

ProcedureCall
		: designator ActualParameters {
			RULE(53,0,ProcedureCall, NONTERM(designator) NONTERM(ActualParameters));
		}
		| designator {
			RULE(53,1,ProcedureCall, NONTERM(designator));
		}
		;

/* 9.3. Statement sequences */

StatementSequence
		: StatementSequence ';' statement {
			RULE(54,0,StatementSequence, NONTERM(StatementSequence) SYMBOL(";") NONTERM(statement));
		}
		| statement {
			RULE(54,1,StatementSequence, NONTERM(statement));
		}
		;

/* 9.4. If statement */

IfStatement
		: IF expression THEN
			StatementSequence
		  elsif_seq
		  else_opt
		  END {
			RULE(55,0,IfStatement, KEYWORD(IF) NONTERM(expression) KEYWORD(THEN)
				NONTERM(StatementSequence) NONTERM(elsif_seq) NONTERM(else_opt)
				KEYWORD(END));
		}
		;

elsif_seq
		: elsif_seq ELSIF expression THEN StatementSequence {
			RULE(56,0,elsif_seq, NONTERM(elsif_seq) KEYWORD(ELSIF)
				NONTERM(expression) KEYWORD(THEN) NONTERM(StatementSequence));
		}
		| /* EMPTY */ {
			RULE(56,1,elsif_seq, EMPTY);
		}
		;

else_opt
		: ELSE StatementSequence {
			RULE(57,0,else_opt, KEYWORD(ELSE) NONTERM(StatementSequence));
		}
		| /* EMPTY */ {
			RULE(57,1,else_opt, EMPTY);
		}
		;

/* 9.5. Case statements */

CaseStatement
		: CASE expression OF
			case_list
			else_opt
		  END {
			RULE(58,0,CaseStatement, KEYWORD(CASE) NONTERM(expression) KEYWORD(OF)
				NONTERM(case_list) NONTERM(else_opt) KEYWORD(END));
		}
		;

case_list
		: case_list '|' case {
			RULE(59,0,case_list, NONTERM(case_list) SYMBOL("|") NONTERM(case));
		}
		| case {
			RULE(59,1,case_list, NONTERM(case));
		}
		;

case
		: CaseLabelList ':' StatementSequence {
			RULE(60,0,case, NONTERM(CaseLabelList) SYMBOL(":") NONTERM(StatementSequence));
		}
		;

/* 9.6. While statements */

WhileStatement
		: WHILE expression DO
			StatementSequence
		  END {
			RULE(61,0,WhileStatement, KEYWORD(WHILE) NONTERM(expression) KEYWORD(DO)
				NONTERM(StatementSequence) KEYWORD(END));
		}
		;

/* 9.7. Repeat statements */

RepeatStatement
		: REPEAT
			StatementSequence
		  UNTIL expression {
			RULE(62,0,RepeatStatement, KEYWORD(REPEAT)
				NONTERM(StatementSequence)
				KEYWORD(UNTIL) NONTERM(expression));
		}
		;

/* 9.8. For statements */

ForStatement
		: FOR IDENT ASSIGN expression TO expression by_opt DO
			StatementSequence
		  END {
			RULE(63,0,ForStatement, KEYWORD(FOR) TERMIN("IDENT:%s") SYMBOL(":=")
				NONTERM(expression) KEYWORD(TO) NONTERM(expression)
				NONTERM(by_opt) KEYWORD(DO) NONTERM(StatementSequence)
				KEYWORD(END), $2);
		}
		;

by_opt
		: BY ConstExpression {
			RULE(64,0,by_opt, KEYWORD(BY) NONTERM(ConstExpression));
		}
		| /* empty */ {
			RULE(64,1,by_opt, EMPTY);
		}
		;

/* 9.9. Loop statements */

LoopStatement
		: LOOP
			StatementSequence
		  END {
			RULE(65,0,LoopStatement, KEYWORD(LOOP) NONTERM(StatementSequence)
				KEYWORD(END));
		}
		;

/* 9.10. With statements */

WithStatement
		: WITH designator DO StatementSequence END {
			RULE(66,0,WithStatement, KEYWORD(WITH) NONTERM(designator)
				KEYWORD(DO) NONTERM(StatementSequence) KEYWORD(END));
		}
		;

/* 10. Procedure declarations */

ProcedureDeclaration
		: ProcedureHeading ';' block IDENT {
            RULE(67,0,ProcedureDeclaration, NONTERM(ProcedureHeading)
                SYMBOL(";") NONTERM(block) TERMIN("IDENT:%s"), $4);
		}
		;

ProcedureHeading
		: PROCEDURE IDENT FormalParameters_opt {
			RULE(68,0,ProcedureHeading, KEYWORD(PROCEDURE) TERMIN("IDENT:%s")
				NONTERM(FormalParameters_opt), $2);
		}
		;

FormalParameters_opt
		: FormalParameters {
			RULE(69,0,FormalParameters_opt, NONTERM(FormalParameters));
		}
		| /* empty */ {
			RULE(69,1,FormalParameters_opt, EMPTY);
		}
		;

block
		: declaration_list_opt
		  BEGIN_StatementSequence_opt
		  END {
			RULE(70,0,block, NONTERM(declaration_list_opt)
				NONTERM(BEGIN_StatementSequence_opt) KEYWORD(END));
		}
		;

declaration_list_opt
		: declaration_list_opt declaration {
			RULE(71,0,declaration_list_opt, NONTERM(declaration_list_opt)
				NONTERM(declaration));
		}
		| /* empty */ {
			RULE(71,1,declaration_list_opt, EMPTY);
		}
		;

BEGIN_StatementSequence_opt
		: TBEGIN StatementSequence {
			RULE(72,0,BEGIN_StatementSequence_opt, KEYWORD(BEGIN)
				NONTERM(StatementSequence));
		}
		| /* empty */ {
			RULE(72,1,BEGIN_StatementSequence_opt, EMPTY);
		}
		;

declaration
		: CONST ConstantDeclaration_list_opt {
			RULE(73,0,declaration, KEYWORD(CONST) NONTERM(ConstantDeclaration_list_opt));
		}
		| TYPE TypeDeclaration_list_opt {
			RULE(73,1,declaration, KEYWORD(TYPE) NONTERM(TypeDeclaration_list_opt));
		}
		| VAR VariableDeclaration_list_opt {
			RULE(73,2,declaration, KEYWORD(VAR) NONTERM(VariableDeclaration_list_opt));
		}
		| ProcedureDeclaration ';' {
			RULE(73,3,declaration, NONTERM(ProcedureDeclaration) SYMBOL(";"));
		}
		| ModuleDeclaration ';' {
			RULE(73,4,declaration, NONTERM(ModuleDeclaration) SYMBOL(";"));
		}
		;

ConstantDeclaration_list_opt
		: ConstantDeclaration_list_opt ConstantDeclaration ';' {
			RULE(74,0,ConstantDeclaration_list_opt, NONTERM(ConstantDeclaration_list_opt)
				NONTERM(ConstantDeclaration) SYMBOL(";"));
		}
		| /* empty */ {
			RULE(74,1,ConstantDeclaration_list_opt, EMPTY);
		}
		;

TypeDeclaration_list_opt
		: TypeDeclaration_list_opt TypeDeclaration ';' {
			RULE(75,0,TypeDeclaration_list_opt, NONTERM(TypeDeclaration_list_opt)
				NONTERM(TypeDeclaration) SYMBOL(";"));
		}
		| /* empty */ {
			RULE(75,1,TypeDeclaration_list_opt, EMPTY);
		}
		;

VariableDeclaration_list_opt
		: VariableDeclaration_list_opt VariableDeclaration ';' {
			RULE(76,0,VariableDeclaration_list_opt, NONTERM(VariableDeclaration_list_opt)
				NONTERM(VariableDeclaration) SYMBOL(";"));
		}
		| /* empty */ {
			RULE(76,1,VariableDeclaration_list_opt, EMPTY);
		}
		;

/* 10.1. Formal parameters */

FormalParameters
		: '(' FPSection_list_opt ')' ':' qualident {
			RULE(77,0,FormalParameters, SYMBOL("(") NONTERM(FPSection_list_opt)
				SYMBOL(")") SYMBOL(":") NONTERM(qualident));
		}
		| '(' FPSection_list_opt ')' {
			RULE(77,1,FormalParameters, SYMBOL("(") NONTERM(FPSection_list_opt)
				SYMBOL(")"));
		}
		;

FPSection_list_opt
		: FPSection_list {
			RULE(78,0,FPSection_list_opt, NONTERM(FPSection_list));
		}
		| /* empty */ {
			RULE(78,1,FPSection_list_opt, EMPTY);
		}
		;

FPSection_list
		: FPSection_list ';' FPSection {
			RULE(79,0,FPSection_list, NONTERM(FPSection_list) SYMBOL(";") NONTERM(FPSection));
		}
		| FPSection {
			RULE(79,1,FPSection_list, NONTERM(FPSection));
		}
		;

FPSection
		: VAR IdentList ':' FormalType {
			RULE(80,0,FPSection, KEYWORD(VAR) NONTERM(IdentList) SYMBOL(":") NONTERM(FormalType));
		}
		|     IdentList ':' FormalType {
			RULE(80,1,FPSection, NONTERM(IdentList) SYMBOL(":") NONTERM(FormalType));
		}
		;

FormalType
		: ARRAY OF qualident {
			RULE(81,0,FormalType, KEYWORD(ARRAY) KEYWORD(OF) NONTERM(qualident));
		}
		| qualident {
			RULE(81,1,FormalType, NONTERM(qualident));
		}
		;

/* 11. Modules */

ModuleDeclaration
		: MODULE IDENT priority_opt ';'
			import_list_opt
			export_opt
		  block IDENT {
			RULE(82,0,ModuleDeclaration, KEYWORD(MODULE) TERMIN("IDENT:%s") NONTERM(priority_opt) SYMBOL(";")
				NONTERM(import_list_opt) NONTERM(export_opt) NONTERM(block) TERMIN("IDENT:%s"), $2, $8);
		}
		;

priority_opt
		: '[' ConstExpression ']' {
			RULE(83,0,priority_opt, SYMBOL("[") NONTERM(ConstExpression) SYMBOL("]"));
		}
		| /* empty */ {
			RULE(83,1,priority_opt, EMPTY);
		}
		;

import_list_opt
		: import_list_opt import {
			RULE(84,0,import_list_opt, NONTERM(import_list_opt) NONTERM(import));
		}
		| /* empty */ {
			RULE(84,1,import_list_opt, EMPTY);
		}
		;

export_opt
		: EXPORT QUALIFIED IdentList ';' {
			RULE(85,0,export_opt, KEYWORD(EXPORT) KEYWORD(QUALIFIED) NONTERM(IdentList) SYMBOL(";"));
		}
		| EXPORT IdentList ';' {
			RULE(85,1,export_opt, KEYWORD(EXPORT) NONTERM(IdentList) SYMBOL(";"));
		}
		| /* empty */ {
			RULE(85,2,export_opt, EMPTY);
		}
		;

import
		: FROM IDENT IMPORT IdentList ';' {
			RULE(86,0,import, KEYWORD(FROM) TERMIN("IDENT:%s") KEYWORD(IMPORT)
				NONTERM(IdentList) SYMBOL(";"), $2);
		}
		|            IMPORT IdentList ';' {
			RULE(86,1,import, KEYWORD(IMPORT) NONTERM(IdentList) SYMBOL(";"));
		}
		;

/* 14. Compilation Units */

DefinitionModule
		: DEFINITION MODULE IDENT ';'
			import_list_opt
			export_opt
			definition_list_opt
		  END IDENT {
			RULE(87,0,DefinitionModule, KEYWORD(DEFINITION) KEYWORD(MODULE) TERMIN("IDENT:%s") SYMBOL(";")
				NONTERM(import_list_opt) NONTERM(export_opt) NONTERM(definition_list_opt)
				KEYWORD(END) TERMIN("IDENT:%s"), $3, $9);
			if ($3 != $9) {
				ERROR("Module identifier at header(%s) doesn't match at end(%s)\n", $3, $9);
			}
		}
		;

definition_list_opt
		: definition_list_opt definition {
			RULE(88,0,definition_list_opt, NONTERM(definition_list_opt) NONTERM(definition));
		}
		| /* empty */ {
			RULE(88,1,definition_list_opt, EMPTY);
		}
		;

definition
		: CONST ConstantDeclaration_list_opt {
			RULE(89,0,definition, KEYWORD(CONST) NONTERM(ConstantDeclaration_list_opt));
		}
		| TYPE opaque_type_list_opt {
			RULE(89,1,definition, KEYWORD(TYPE) NONTERM(opaque_type_list_opt));
		}
		| VAR VariableDeclaration_list_opt {
			RULE(89,2,definition, KEYWORD(VAR) NONTERM(VariableDeclaration_list_opt));
		}
		| ProcedureHeading ';' {
			RULE(89,3,definition, NONTERM(ProcedureHeading) SYMBOL(";"));
		}
		| DefinitionModule ';' {
			RULE(89,4,definition, NONTERM(DefinitionModule) SYMBOL(";"));
		}
		;

opaque_type_list_opt
		: opaque_type_list_opt opaque_type {
			RULE(90,0,opaque_type_list_opt, NONTERM(opaque_type_list_opt) NONTERM(opaque_type));
		}
		| /* empty */ {
			RULE(90,1,opaque_type_list_opt, EMPTY);
		}
		;

opaque_type
		: IDENT '=' type ';' {
			RULE(91,0,opaque_type, TERMIN("IDENT:%s") SYMBOL("=") NONTERM(type) SYMBOL(";"), $1);
		}
		| IDENT ';' {
			RULE(91,1,opaque_type, TERMIN("IDENT:%s") SYMBOL(";"), $1);
		}
		;

ProgramModule
		: MODULE IDENT priority_opt ';'
			import_list_opt
		  block IDENT {
			RULE(92,0,ProgramModule, KEYWORD(MODULE) TERMIN("IDENT:%s") NONTERM(priority_opt) SYMBOL(";")
				NONTERM(import_list_opt) NONTERM(block) TERMIN("IDENT:%s"), $2, $7);
			if ($2 != $7) {
				ERROR("Module identifier at header(%s) doesn't match at end(%s)\n", $2, $7);
			}
		}
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
