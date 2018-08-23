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

#define TERMIN(t) " \033[34m" #t
#define NONTERM(s) " \033[37m<\033[32m" #s "\033[37m>"
#define SYMBOL(op) " \033[31m" #op
#define KEYWORD(k) " \033[37m" #k
#define EMPTY " \033[34m/* EMPTY */"

#define RULE(n,lft, rgt, ...) do{ \
			printf(F("\033[37mR-%03d: \033[37m<\033[36m"#lft"\033[37m>\033[33m ::=" rgt "\033[m\n"),n,##__VA_ARGS__); \
		}while(0)
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
		: DefinitionModule '.' {
			RULE(1, CompilationUnit, NONTERM(DefinitionModule) SYMBOL('.'));
		}
		| IMPLEMENTATION ProgramModule '.' {
			RULE(2, CompilationUnit, KEYWORD(IMPLEMENTATION) NONTERM(ProgramModule) SYMBOL('.'));
		}
		| ProgramModule '.' {
			RULE(3, CompilationUnit, NONTERM(ProgramModule) SYMBOL('.'));
		}
		;

qualident
		: qualifier '.' IDENT {
			RULE(4, qualident, NONTERM(qualifier) SYMBOL('.') TERMIN(IDENT));
		}
		| IDENT {
			RULE(5,qualident, TERMIN(IDENT));
		}
		;

qualifier
		: qualifier '.' QUAL_IDENT {
			RULE(6,qualifier, NONTERM(qualifier) SYMBOL('.') TERMIN(QUAL_IDENT));
		}
		| QUAL_IDENT {
			RULE(7,qualifier, TERMIN(QUAL_IDENT));
		}
		;

/* 5. Constant declarations */

ConstantDeclaration
		: IDENT '=' ConstExpression {
			RULE(8,ConstantDeclaration, TERMIN(IDENT) SYMBOL('=') NONTERM(ConstExpression));
		}
		;

ConstExpression
		: SimpleConstExpr relation SimpleConstExpr {
			RULE(9,ConstExpression, NONTERM(SimpleConstExpr) NONTERM(relation) NONTERM(SimpleConstExpr));
		}
		| SimpleConstExpr {
			RULE(10,ConstExpression, NONTERM(SimpleConstExpr));
		}
		;

relation
		: '=' {
			RULE(11,relation, SYMBOL('='));
		}
		| '#' {
			RULE(12,relation, SYMBOL('#'));
		}
		| NE {
			RULE(13,relation, SYMBOL('<>'));
		}
		| '<' {
			RULE(14,relation, SYMBOL('<'));
		}
		| LE {
			RULE(15,relation, SYMBOL('<='));
		}
		| '>' {
			RULE(16,relation, SYMBOL('>'));
		}
		| GE {
			RULE(17,relation, SYMBOL('>='));
		}
		| IN {
			RULE(18,relation, KEYWORD(IN));
		}
		;

SimpleConstExpr
		: ConstTerm_list {
			RULE(19,SimpleConstExpr, NONTERM(ConstTerm_list));
		}
		;

ConstTerm_list
		: ConstTerm_list AddOperator ConstTerm {
			RULE(20,ConstTerm_list, NONTERM(ConstTerm_list) NONTERM(AddOperator) NONTERM(ConstTerm));
		}
		| add_op_opt ConstTerm {
			RULE(21,ConstTerm_list, NONTERM(add_op_opt) NONTERM(ConstTerm));
		}
		;

add_op_opt
		: '+' {
			RULE(22,add_op_opt, SYMBOL('+'));
		}
		| '-' {
			RULE(23,add_op_opt, SYMBOL('-'));
		}
		| /* empty */ {
			RULE(24,add_op_opt, EMPTY);
		}
		;

AddOperator
		: '+' {
			RULE(25,AddOperator, SYMBOL('+'));
		}
		| '-' {
			RULE(26,AddOperator, SYMBOL('-'));
		}
		| OR {
			RULE(27,AddOperator, KEYWORD(OR));
		}
		;

ConstTerm
		: ConstTerm MulOperator ConstFactor {
			RULE(28,ConstTerm, NONTERM(ConstTerm) NONTERM(MulOperator) NONTERM(ConstFactor));
		}
		| ConstFactor {
			RULE(29,ConstTerm, NONTERM(ConstFactor));
		}
		;

MulOperator
		: '*' {
			RULE(30,MulOperator, SYMBOL('*'));
		}
		| '/' {
			RULE(31,MulOperator, SYMBOL('/'));
		}
		| DIV {
			RULE(32,MulOperator, KEYWORD(DIV));
		}
		| MOD {
			RULE(33,MulOperator, KEYWORD(MOD));
		}
		| AND {
			RULE(34,MulOperator, KEYWORD(AND));
		}
		| '&' {
			RULE(35,MulOperator, SYMBOL('&'));
		}
		;

ConstFactor
		: qualident {
			RULE(36,ConstFactor, NONTERM(qualident));
		}
		| NUMBER {
			RULE(37,ConstFactor, TERMIN(NUMBER));
		}
		| STRING {
			RULE(38,ConstFactor, TERMIN(STRING));
		}
		| CHARLIT {
			RULE(39,ConstFactor, TERMIN(CHARLIT));
		}
		| set {
			RULE(40,ConstFactor, NONTERM(set));
		}
		| '(' ConstExpression ')' {
			RULE(41,ConstFactor, SYMBOL('(') NONTERM(ConstExpression) SYMBOL(')'));
		}
		| NOT ConstFactor {
			RULE(42,ConstFactor, KEYWORD(NOT) NONTERM(ConstFactor));
		}
		;

set
		: qualident '{' element_list_opt '}' {
			RULE(43,set, NONTERM(qualident) SYMBOL('{') NONTERM(element_list_opt) SYMBOL('}'));
		}
		| '{' element_list_opt '}' {
			RULE(44,set, SYMBOL('{') NONTERM(element_list_opt) SYMBOL('}'));
		}
		;

element_list_opt
		: element_list {
			RULE(45,element_list_opt, NONTERM(element_list));
		}
		| /* empty */ {
			RULE(46,element_list_opt, EMPTY);
		}
		;

element_list
		: element_list ',' element {
			RULE(47,element_list, NONTERM(element_list) SYMBOL(',') NONTERM(element));
		}
		| element {
			RULE(48,element_list, NONTERM(element));
		}
		;

element
		: ConstExpression RANGE ConstExpression {
			RULE(49,element, NONTERM(ConstExpression) SYMBOL('..') NONTERM(ConstExpression));
		}
		| ConstExpression  {
			RULE(50,element, NONTERM(ConstExpression));
		}
		;


/* 6. Type declarations */

TypeDeclaration
		: IDENT '=' type {
			RULE(51,TypeDeclaration, TERMIN(IDENT) SYMBOL('=') NONTERM(type));
		}
		;

type
		: SimpleType {
			RULE(52,type, NONTERM(SimpleType));
		}
		| ArrayType {
			RULE(53,type, NONTERM(ArrayType));
		}
		| RecordType {
			RULE(54,type, NONTERM(RecordType));
		}
		| SetType {
			RULE(55,type, NONTERM(SetType));
		}
		| PointerType {
			RULE(56,type, NONTERM(PointerType));
		}
		| ProcedureType {
			RULE(57,type, NONTERM(ProcedureType));
		}
		;

SimpleType
		: qualident {
			RULE(58,SimpleType, NONTERM(qualident));
		}
		| enumeration {
			RULE(59,SimpleType, NONTERM(enumeration));
		}
		| SubrangeType {
			RULE(60,SimpleType, NONTERM(SubrangeType));
		}
		;

/* 6.2. Enumerations */

enumeration
		: '(' IdentList ')' {
			RULE(61,enumeration, SYMBOL('(') NONTERM(IdentList) SYMBOL(')'));
		}
		;

IdentList
		: IdentList ',' IDENT {
			RULE(62,IdentList, NONTERM(IdentList) SYMBOL(',') TERMIN(IDENT));
		}
		| IDENT {
			RULE(63,IdentList, TERMIN(IDENT));
		}
		;

/* 6.3. Subrange types */

SubrangeType
		: '[' ConstExpression RANGE ConstExpression ']' {
			RULE(64,SubrangeType, SYMBOL('[') NONTERM(ConstExpression) SYMBOL('..') NONTERM(ConstExpression));
		}
		;

/* 6.4 Array types */

ArrayType
		: ARRAY SimpleType_list OF type {
			RULE(65,ArrayType, KEYWORD(ARRAY) NONTERM(SimpleType_list) KEYWORD(OF) NONTERM(type));
		}
		;

SimpleType_list
		: SimpleType_list ',' SimpleType {
			RULE(66,SimpleType_list, NONTERM(SimpleType_list) SYMBOL(',') NONTERM(SimpleType));
		}
		| SimpleType {
			RULE(67,SimpleType_list, NONTERM(SimpleType));
		}
		;

/* 6.5. Record types */

RecordType
		: RECORD
			FieldListSequence
		  END {
			RULE(68,RECORD, KEYWORD(RECORD) NONTERM(FieldListSequence) KEYWORD(END));
		}
		;

FieldListSequence
		: FieldListSequence ';' FieldList {
			RULE(69,FieldListSequence, NONTERM(FieldListSequence) SYMBOL(';') NONTERM(FieldList));
		}
		| FieldList {
			RULE(70,FieldListSequence, NONTERM(FieldList));
		}
		;

FieldList
		: IdentList ':' type {
			RULE(71,FieldList, NONTERM(IdentList) SYMBOL(':') NONTERM(type));
		}
		| CASE case_ident OF
				variant_list
				ELSE_FieldListSequence
		  END {
			RULE(72,FieldList, KEYWORD(CASE) NONTERM(case_ident) KEYWORD(OF)
			NONTERM(variant_list) NONTERM(ELSE_FieldListSequence) KEYWORD(END));
		}
		| /* empty */ {
			RULE(73,FieldList, EMPTY);
		}
		;

case_ident
		: IDENT ':' qualident  {
			RULE(74,case_ident, TERMIN(IDENT) SYMBOL(':') NONTERM(qualident));
		}
		| 			qualident {
			RULE(75,case_ident, NONTERM(qualident));
		}
		;

variant_list
		: variant_list '|' variant {
			RULE(76,variant_list, NONTERM(variant_list) SYMBOL('|') NONTERM(variant));
		}
		| variant {
			RULE(77,variant_list, NONTERM(variant));
		}
		;

ELSE_FieldListSequence
		: ELSE FieldListSequence {
			RULE(78,ELSE_FieldListSequence, KEYWORD(ELSE) NONTERM(FieldListSequence));
		}
		| /* empty */ {
			RULE(79,ELSE_FieldListSequence, EMPTY);
		}
		;

variant
		: CaseLabelList ':' FieldListSequence {
			RULE(80,variant, NONTERM(CaseLabelList) SYMBOL(':') NONTERM(FieldListSequence));
		}
		;

CaseLabelList
		: CaseLabelList ',' CaseLabels {
			RULE(81,CaseLabelList, NONTERM(CaseLabelList) SYMBOL(',') NONTERM(CaseLabels));
		}
		| CaseLabels {
			RULE(82,CaseLabelList, NONTERM(CaseLabels));
		}
		;

CaseLabels
		: ConstExpression RANGE ConstExpression {
			RULE(83,CaseLabels, NONTERM(ConstExpression) SYMBOL('..') NONTERM(ConstExpression));
		}
		| ConstExpression {
			RULE(84,CaseLabels, NONTERM(ConstExpression));
		}
		;

/* 6.6. Set types */

SetType
		: SET OF SimpleType {
			RULE(85,SetType, KEYWORD(SET) KEYWORD(OF) NONTERM(SimpleType));
		}
		;

/* 6.7. Pointer types */

PointerType
		: POINTER TO type {
			RULE(86,PointerType, KEYWORD(POINTER) KEYWORD(TO) NONTERM(type));
		}
		;

/* 6.8 Procedure types */

ProcedureType
		: PROCEDURE FormalTypeList {
			RULE(87,ProcedureType, KEYWORD(PROCEDURE) NONTERM(FormalTypeList));
		}
		| PROCEDURE {
			RULE(88,ProcedureType, KEYWORD(PROCEDURE));
		}
		;

FormalTypeList
		: paren_formal_parameter_type_list_opt ':' qualident {
			RULE(89,FormalTypeList, NONTERM(paren_formal_parameter_type_list_opt)
				SYMBOL(':') NONTERM(qualident));
		}
		| paren_formal_parameter_type_list_opt {
			RULE(90,FormalTypeList, NONTERM(paren_formal_parameter_type_list_opt));
		}
		;

paren_formal_parameter_type_list_opt
		: '(' formal_parameter_type_list_opt ')' {
			RULE(91,paren_formal_parameter_type_list_opt, SYMBOL('(')
				NONTERM(formal_parameter_type_list_opt) SYMBOL(')'));
		}
		;

formal_parameter_type_list_opt
		: formal_parameter_type_list {
			RULE(92,formal_parameter_type_list_opt,
				NONTERM(formal_parameter_type_list_opt));
		}
		| /* EMPTY */ {
			RULE(93,formal_parameter_type_list_opt, EMPTY);
		}
		;

formal_parameter_type_list
		: formal_parameter_type_list ',' formal_parameter_type {
			RULE(94,formal_parameter_type_list, NONTERM(formal_parameter_type_list)
				SYMBOL(',') NONTERM(formal_parameter_type));
		}
		| formal_parameter_type {
			RULE(95,formal_parameter_type_list, NONTERM(formal_parameter_type));
		}
		;

formal_parameter_type
		: VAR FormalType {
			RULE(96,formal_parameter_type, KEYWORD(VAR) NONTERM(FormalType));
		}
		| FormalType {
			RULE(97,formal_parameter_type, NONTERM(FormalType));
		}
		;

VariableDeclaration
		: IdentList ':' type {
			RULE(98,VariableDeclaration, NONTERM(IdentList) SYMBOL(':') NONTERM(type));
		}
		;

/* 8. Expressions */
/* 8.1. Operands */

designator
		: designator '.' IDENT {
			RULE(99,designator, NONTERM(designator) SYMBOL('.') TERMIN(IDENT));
		}
		| designator '[' ExpList ']' {
			RULE(100,designator, NONTERM(designator) SYMBOL('[') NONTERM(ExpList) SYMBOL(']'));
		}
		| designator '^' {
			RULE(101,designator, NONTERM(designator) SYMBOL('^'));
		}
		| qualident {
			RULE(102,designator, NONTERM(qualident));
		}
		;

ExpList
		: ExpList ',' expression {
			RULE(103,ExpList, NONTERM(ExpList) SYMBOL(',') NONTERM(expression));
		}
		| expression {
			RULE(104,ExpList, NONTERM(expression));
		}
		;

/* 8.2 Operators */

expression
		: SimpleExpression relation SimpleExpression {
			RULE(105,expression, NONTERM(SimpleExpression)
				NONTERM(relation) NONTERM(SimpleExpression));
		}
		| SimpleExpression {
			RULE(106,expression, NONTERM(SimpleExpression));
		}
		;

SimpleExpression
		: SimpleExpression AddOperator term {
			RULE(107,SimpleExpression, NONTERM(SimpleExpression) NONTERM(AddOperator) NONTERM(term));
		}
		| add_op_opt term {
			RULE(108,SimpleExpression, NONTERM(add_op_opt) NONTERM(term));
		}
		;

term
		: term MulOperator factor {
			RULE(109,term, NONTERM(term) NONTERM(MulOperator) NONTERM(factor));
		}
		| factor {
			RULE(110,term, NONTERM(factor));
		}
		;

factor
		: NUMBER {
			RULE(111,factor, TERMIN(NUMBER));
		}
		| STRING {
			RULE(112,factor, TERMIN(STRING));
		}
		| CHARLIT {
			RULE(113,factor, TERMIN(CHARLIT));
		}
		| set {
			RULE(114,factor, NONTERM(set));
		}
		| designator ActualParameters {
			RULE(115,factor, NONTERM(designator) NONTERM(ActualParameters));
		}
		| designator {
			RULE(116,factor, NONTERM(designator));
		}
		| '(' expression ')' {
			RULE(117,factor, SYMBOL('(') NONTERM(expression) SYMBOL(')'));
		}
		| NOT factor {
			RULE(118,factor, KEYWORD(NOT) NONTERM(factor));
		}
		;

ActualParameters
		: '(' ExpList ')' {
			RULE(119,ActualParameters, SYMBOL('(') NONTERM(ExpList) SYMBOL(')'));
		}
		| '(' ')' {
			RULE(120,ActualParameters, SYMBOL('(') SYMBOL(')'));
		}
		;

/* 9. Statements */

statement
		: assignment {
			RULE(121,statement, NONTERM(assignment));
		}
		| ProcedureCall {
			RULE(122,statement, NONTERM(ProcedureCall));
		}
		| IfStatement {
			RULE(123,statement, NONTERM(IfStatement));
		}
		| CaseStatement {
			RULE(124,statement, NONTERM(CaseStatement));
		}
		| WhileStatement {
			RULE(125,statement, NONTERM(WhileStatement));
		}
		| RepeatStatement {
			RULE(126,statement, NONTERM(RepeatStatement));
		}
		| LoopStatement {
			RULE(127,statement, NONTERM(LoopStatement));
		}
		| ForStatement {
			RULE(128,statement, NONTERM(ForStatement));
		}
		| WithStatement {
			RULE(129,statement, NONTERM(WithStatement));
		}
		| EXIT {
			RULE(130,statement, KEYWORD(EXIT));
		}
		| TRETURN expression {
			RULE(131,statement, KEYWORD(RETURN)NONTERM(expression));
		}
		| TRETURN {
			RULE(132,statement, KEYWORD(RETURN));
		}
		;

/* 9.1. Assignments */

assignment
		: designator ASSIGN expression {
			RULE(133,assignment, NONTERM(designator) SYMBOL(':=') NONTERM(expression));
		}
		;

/* 9.2. Procedure calls */

ProcedureCall
		: designator ActualParameters {
			RULE(134,ProcedureCall, NONTERM(designator) NONTERM(ActualParameters));
		}
		| designator {
			RULE(135,ProcedureCall, NONTERM(designator));
		}
		;

/* 9.3. Statement sequences */

StatementSequence
		: StatementSequence ';' statement {
			RULE(136,StatementSequence, NONTERM(StatementSequence) SYMBOL(';') NONTERM(statement));
		}
		| statement {
			RULE(137,StatementSequence, NONTERM(statement));
		}
		;

/* 9.4. If statement */

IfStatement
		: IF expression THEN
			StatementSequence
		  elsif_seq
		  else_opt
		  END {
			RULE(138,IfStatement, KEYWORD(IF) NONTERM(expression) KEYWORD(THEN)
				NONTERM(StatementSequence) NONTERM(elsif_seq) NONTERM(else_opt)
				KEYWORD(END));
		}
		;

elsif_seq
		: elsif_seq ELSIF expression THEN StatementSequence {
			RULE(139,elsif_seq, NONTERM(elsif_seq) KEYWORD(ELSIF) NONTERM(expression) KEYWORD(THEN) NONTERM(StatementSequence));
		}
		| /* EMPTY */ {
			RULE(140,elsif_seq, EMPTY);
		}
		;

else_opt
		: ELSE StatementSequence {
			RULE(141,else_opt, KEYWORD(ELSE) NONTERM(StatementSequence));
		}
		| /* EMPTY */ {
			RULE(142,else_opt, EMPTY);
		}
		;

/* 9.5. Case statements */

CaseStatement
		: CASE expression OF
			case_list
			else_opt
		  END {
			RULE(143,CaseStatement, KEYWORD(CASE) NONTERM(expression) KEYWORD(OF)
				NONTERM(case_list) NONTERM(else_opt) KEYWORD(END));
		}
		;

case_list
		: case_list '|' case {
			RULE(144,case_list, NONTERM(case_list) SYMBOL('|') NONTERM(case));
		}
		| case {
			RULE(145,case_list, NONTERM(case));
		}
		;

case
		: CaseLabelList ':' StatementSequence {
			RULE(146,case, NONTERM(CaseLabelList) SYMBOL(':') NONTERM(StatementSequence));
		}
		;

/* 9.6. While statements */

WhileStatement
		: WHILE expression DO
			StatementSequence
		  END {
			RULE(147,WhileStatement, KEYWORD(WHILE) NONTERM(expression) KEYWORD(DO)
				NONTERM(StatementSequence) KEYWORD(END));
		}
		;

/* 9.7. Repeat statements */

RepeatStatement
		: REPEAT
			StatementSequence
		  UNTIL expression {
			RULE(148,RepeatStatement, KEYWORD(REPEAT)
				NONTERM(StatementSequence)
				KEYWORD(UNTIL) NONTERM(expression));
		}
		;

/* 9.8. For statements */

ForStatement
		: FOR IDENT ASSIGN expression TO expression by_opt DO
			StatementSequence
		  END {
			RULE(149,ForStatement, KEYWORD(FOR) TERMIN(IDENT) SYMBOL(':=')
				NONTERM(expression) KEYWORD(TO) NONTERM(expression)
				NONTERM(by_opt) KEYWORD(DO) NONTERM(StatementSequence)
				KEYWORD(END));
		}
		;

by_opt
		: BY ConstExpression {
			RULE(150,by_opt, KEYWORD(BY) NONTERM(ConstExpression));
		}
		| /* empty */ {
			RULE(151,by_opt, EMPTY);
		}
		;

/* 9.9. Loop statements */

LoopStatement
		: LOOP
			StatementSequence
		  END {
			RULE(152,LoopStatement, KEYWORD(LOOP) NONTERM(StatementSequence)
				KEYWORD(END));
		}
		;

/* 9.10. With statements */

WithStatement
		: WITH designator DO
			StatementSequence
		  END {
			RULE(153,WithStatement, KEYWORD(WITH) NONTERM(designator)
				KEYWORD(DO) NONTERM(StatementSequence) KEYWORD(END));
		}
		;

/* 10. Procedure declarations */

ProcedureDeclaration
		: ProcedureHeading ';'
			block IDENT {
				RULE(154,ProcedureDeclaration, NONTERM(ProcedureHeading)
					SYMBOL(';') NONTERM(block) TERMIN(IDENT));
			}
		;

ProcedureHeading
		: PROCEDURE IDENT FormalParameters_opt {
			RULE(155,ProcedureHeading, KEYWORD(PROCEDURE) TERMIN(IDENT)
				NONTERM(FormalParameters_opt));
		}
		;

FormalParameters_opt
		: FormalParameters {
			RULE(156,FormalParameters_opt, NONTERM(FormalParameters));
		}
		| /* empty */ {
			RULE(157,FormalParameters_opt, EMPTY);
		}
		;

block
		: declaration_list_opt
		  BEGIN_StatementSequence_opt
		  END {
			RULE(158,block, NONTERM(declaration_list_opt)
				NONTERM(BEGIN_StatementSequence_opt) KEYWORD(END));
		}
		;

declaration_list_opt
		: declaration_list_opt declaration {
			RULE(159,declaration_list_opt, NONTERM(declaration_list_opt)
				NONTERM(declaration));
		}
		| /* empty */ {
			RULE(160,declaration_list_opt, EMPTY);
		}
		;

BEGIN_StatementSequence_opt
		: TBEGIN StatementSequence {
			RULE(161,BEGIN_StatementSequence_opt, KEYWORD(BEGIN)
				NONTERM(StatementSequence));
		}
		| /* empty */ {
			RULE(162,BEGIN_StatementSequence_opt, EMPTY);
		}
		;

declaration
		: CONST ConstantDeclaration_list_opt {
			RULE(163,declaration, KEYWORD(CONST) NONTERM(ConstantDeclaration_list_opt));
		}
		| TYPE TypeDeclaration_list_opt {
			RULE(164,declaration, KEYWORD(TYPE) NONTERM(TypeDeclaration_list_opt));
		}
		| VAR VariableDeclaration_list_opt {
			RULE(165,declaration, KEYWORD(VAR) NONTERM(VariableDeclaration_list_opt));
		}
		| ProcedureDeclaration ';' {
			RULE(166,declaration, NONTERM(ProcedureDeclaration) SYMBOL(';'));
		}
		| ModuleDeclaration ';' {
			RULE(167,declaration, NONTERM(ModuleDeclaration) SYMBOL(';'));
		}
		;

ConstantDeclaration_list_opt
		: ConstantDeclaration_list_opt ConstantDeclaration ';' {
			RULE(168,ConstantDeclaration_list_opt, NONTERM(ConstantDeclaration_list_opt)
				NONTERM(ConstantDeclaration) SYMBOL(';'));
		}
		| /* empty */ {
			RULE(169,ConstantDeclaration_list_opt, EMPTY);
		}
		;

TypeDeclaration_list_opt
		: TypeDeclaration_list_opt TypeDeclaration ';' {
			RULE(170,TypeDeclaration_list_opt, NONTERM(TypeDeclaration_list_opt)
				NONTERM(TypeDeclaration) SYMBOL(';'));
		}
		| /* empty */ {
			RULE(171,TypeDeclaration_list_opt, EMPTY);
		}
		;

VariableDeclaration_list_opt
		: VariableDeclaration_list_opt VariableDeclaration ';' {
			RULE(172,VariableDeclaration_list_opt, NONTERM(VariableDeclaration_list_opt)
				NONTERM(VariableDeclaration) SYMBOL(';'));
		}
		| /* empty */ {
			RULE(173,VariableDeclaration_list_opt, EMPTY);
		}
		;

/* 10.1. Formal parameters */

FormalParameters
		: '(' FPSection_list_opt ')' ':' qualident {
			RULE(174,FormalParameters, SYMBOL('(') NONTERM(FPSection_list_opt)
				SYMBOL(')') SYMBOL(':') NONTERM(qualident));
		}
		| '(' FPSection_list_opt ')' {
			RULE(175,FormalParameters, SYMBOL('(') NONTERM(FPSection_list_opt)
				SYMBOL(')'));
		}
		;

FPSection_list_opt
		: FPSection_list {
			RULE(176,FPSection_list_opt, NONTERM(FPSection_list));
		}
		| /* empty */ {
			RULE(177,FPSection_list_opt, EMPTY);
		}
		;

FPSection_list
		: FPSection_list ';' FPSection {
			RULE(178,FPSection_list, NONTERM(FPSection_list) SYMBOL(';') NONTERM(FPSection));
		}
		| FPSection {
			RULE(179,FPSection_list, NONTERM(FPSection));
		}
		;

FPSection
		: VAR IdentList ':' FormalType {
			RULE(180,FPSection, KEYWORD(VAR) NONTERM(IdentList) SYMBOL(':') NONTERM(FormalType));
		}
		|     IdentList ':' FormalType {
			RULE(181,FPSection, NONTERM(IdentList) SYMBOL(':') NONTERM(FormalType));
		}
		;

FormalType
		: ARRAY OF qualident {
			RULE(182,FormalType, KEYWORD(ARRAY) KEYWORD(OF) NONTERM(qualident));
		}
		| qualident {
			RULE(183,FormalType, NONTERM(qualident));
		}
		;

/* 11. Modules */

ModuleDeclaration
		: MODULE IDENT priority_opt ';'
			import_list_opt
			export_opt
		  block IDENT {
			RULE(184,ModuleDeclaration, KEYWORD(MODULE) TERMIN(IDENT) NONTERM(priority_opt) SYMBOL(';')
				NONTERM(import_list_opt) NONTERM(export_opt) NONTERM(block) TERMIN(IDENT));
		}
		;

priority_opt
		: '[' ConstExpression ']' {
			RULE(185,priority_opt, SYMBOL('[') NONTERM(ConstExpression) SYMBOL(']'));
		}
		| /* empty */ {
			RULE(186,priority_opt, EMPTY);
		}
		;

import_list_opt
		: import_list_opt import {
			RULE(187,import_list_opt, NONTERM(import_list_opt) NONTERM(import));
		}
		| /* empty */ {
			RULE(188,import_list_opt, EMPTY);
		}
		;

export_opt
		: EXPORT QUALIFIED IdentList ';' {
			RULE(189,export_opt, KEYWORD(EXPORT) KEYWORD(QUALIFIED) NONTERM(IdentList) SYMBOL(';'));
		}
		| EXPORT IdentList ';' {
			RULE(190,export_opt, KEYWORD(EXPORT) NONTERM(IdentList) SYMBOL(';'));
		}
		| /* empty */ {
			RULE(191,export_opt, EMPTY);
		}
		;

import
		: FROM IDENT IMPORT IdentList ';' {
			RULE(192,import, KEYWORD(FROM) TERMIN(IDENT) KEYWORD(IMPORT)
				NONTERM(IdentList) SYMBOL(';'));
		}
		|            IMPORT IdentList ';' {
			RULE(193,import, KEYWORD(IMPORT) NONTERM(IdentList) SYMBOL(';'));
		}
		;

/* 14. Compilation Units */

DefinitionModule
		: DEFINITION MODULE IDENT ';'
			import_list_opt
			export_opt
			definition_list_opt
		  END IDENT {
			RULE(194,DefinitionModule, KEYWORD(DEFINITION) KEYWORD(MODULE) TERMIN(IDENT) SYMBOL(';')
				NONTERM(import_list_opt) NONTERM(export_opt) NONTERM(definition_list_opt)
				KEYWORD(END) TERMIN(IDENT));
		}
		;

definition_list_opt
		: definition_list_opt definition {
			RULE(195,definition_list_opt, NONTERM(definition_list_opt) NONTERM(definition));
		}
		| /* empty */ {
			RULE(196,definition_list_opt, EMPTY);
		}
		;

definition
		: CONST ConstantDeclaration_list_opt {
			RULE(197,definition, KEYWORD(CONST) NONTERM(ConstantDeclaration_list_opt));
		}
		| TYPE opaque_type_list_opt {
			RULE(198,definition, KEYWORD(TYPE) NONTERM(opaque_type_list_opt));
		}
		| VAR VariableDeclaration_list_opt {
			RULE(199,definition, KEYWORD(VAR) NONTERM(VariableDeclaration_list_opt));
		}
		| ProcedureHeading ';' {
			RULE(200,definition, NONTERM(ProcedureHeading) SYMBOL(';'));
		}
		| DefinitionModule ';' {
			RULE(201,definition, NONTERM(DefinitionModule) SYMBOL(';'));
		}
		;

opaque_type_list_opt
		: opaque_type_list_opt opaque_type {
			RULE(202,opaque_type_list_opt, NONTERM(opaque_type_list_opt) NONTERM(opaque_type));
		}
		| /* empty */ {
			RULE(203,opaque_type_list_opt, EMPTY);
		}
		;

opaque_type
		: IDENT '=' type ';' {
			RULE(204,opaque_type, TERMIN(IDENT) SYMBOL('=') NONTERM(type) SYMBOL(';'));
		}
		| IDENT ';' {
			RULE(205,opaque_type, TERMIN(IDENT) SYMBOL(';'));
		}
		;

ProgramModule
		: MODULE IDENT priority_opt ';'
			import_list_opt
		  block IDENT {
			RULE(206,ProgramModule, KEYWORD(MODULE) TERMIN(IDENT) NONTERM(priority_opt) SYMBOL(';')
				NONTERM(import_list_opt) NONTERM(block) TERMIN(IDENT));
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
