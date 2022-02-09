%{
/* m2p.y -- parser for MODULA-2.
 * Date: Tue Aug 21 08:10:26 EEST 2018
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Copyright: (C) 2018 Luis Colorado.  All rights reserved.
 * License: BSD
 * Based on the MODULA-2 report by N. Wirth, 1980.
 * See: https://doi.org/10.3929/ethz-a-000189918 (1980)
 * See: https://doi.org/10.3929/ethz-a-000153014 (1978)
 */

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <stravl.h>

#include "global.h"
#include "m2p.h"

#ifndef USE_COLOR
#	warning please, define USE_COLOR to compile this source with color support.
#endif

%}

%token <string> AND ARRAY TBEGIN BY CASE CONST DEFINITION DIV DO ELSE ELSIF
%token <string> END EXIT EXPORT FOR FROM IF IMPLEMENTATION IMPORT IN LOOP
%token <string> MOD MODULE NOT OF OR POINTER PROCEDURE QUALIFIED RECORD
%token <string> REPEAT TRETURN SET THEN TO TYPE UNTIL VAR WHILE WITH

%token <string> ASSIGN LE GE NE RANGE
%type  <string> '+' '-' '*' '/' '&' '.' ',' ';' '{' '}' '[' ']' '(' ')'
%type  <string> '^' '=' '#' '<' '>' ':' '|'

%token <integer> INTEGER CHARLIT
%token <string>  STRING IDENT MOD_IDENT
%token <real>    REAL

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
    const char         *string;
    int                 integer;
    double              real;
    union tree_node     nonterm;
}

%%

CompilationUnit
        : DefinitionModule '.' {
            $$ = alloc_NONTERMINAL(CL_CompilationUnit, 1, 2, $1, alloc_SYMBOL('.', $2));
            if (global.flags & GL_FLAG_VERBOSE_PARSE_TREE)
            	print_subtree($$, stdout, ROOT_NODE);
        }
        | IMPLEMENTATION ProgramModule '.' {
            $$ = alloc_NONTERMINAL(CL_CompilationUnit, 2, 3, alloc_SYMBOL(IMPLEMENTATION, $1), $2, alloc_SYMBOL('.', $3));
            if (global.flags & GL_FLAG_VERBOSE_PARSE_TREE)
                print_subtree($$, stdout, ROOT_NODE);
        }
        | ProgramModule '.' {
            $$ = alloc_NONTERMINAL(CL_CompilationUnit, 3, 2, $1, alloc_SYMBOL('.', $2));
            if (global.flags & GL_FLAG_VERBOSE_PARSE_TREE)
                print_subtree($$, stdout, ROOT_NODE);
        }
        ;

qualident
        : qualifier '.' IDENT {
            $$ = alloc_NONTERMINAL(CL_qualident, 4, 3, $1, alloc_SYMBOL('.', $2), alloc_IDENT($3));
        }
        | IDENT {
            $$ = alloc_NONTERMINAL(CL_qualident, 5, 1, alloc_IDENT($1));
        }
        ;

qualifier
        : qualifier '.' MOD_IDENT {
            $$ = alloc_NONTERMINAL(CL_qualifier, 6, 3, $1, alloc_SYMBOL('.', $2), alloc_MOD_IDENT($3));
        }
        | MOD_IDENT {
            $$ = alloc_NONTERMINAL(CL_qualifier, 7, 1, alloc_MOD_IDENT($1));
        }
        ;

/* 5. Constant declarations */

ConstantDeclaration
        : IDENT '=' ConstExpression {
            $$ = alloc_NONTERMINAL(CL_ConstantDeclaration, 8, 3, alloc_IDENT($1), alloc_SYMBOL('=', $2), $3);
        }
        ;

ConstExpression
        : SimpleConstExpr relation SimpleConstExpr {
            $$ = alloc_NONTERMINAL(CL_ConstExpression, 9, 3, $1, $2, $3);
        }
        | SimpleConstExpr {
            $$ = alloc_NONTERMINAL(CL_ConstExpression, 10, 1, $1);
        }
        ;

relation
        : '=' {
            $$ = alloc_NONTERMINAL(CL_relation, 11, 1, alloc_SYMBOL('=', $1));
        }
        | '#' {
            $$ = alloc_NONTERMINAL(CL_relation, 12, 1, alloc_SYMBOL('#', $1));
        }
        | NE {
            $$ = alloc_NONTERMINAL(CL_relation, 13, 1, alloc_SYMBOL(NE, $1));
        }
        | '<' {
            $$ = alloc_NONTERMINAL(CL_relation, 14, 1, alloc_SYMBOL('<', $1));
        }
        | LE {
            $$ = alloc_NONTERMINAL(CL_relation, 15, 1, alloc_SYMBOL(LE, $1));
        }
        | '>' {
            $$ = alloc_NONTERMINAL(CL_relation, 16, 1, alloc_SYMBOL('>', $1));
        }
        | GE {
            $$ = alloc_NONTERMINAL(CL_relation, 17, 1, alloc_SYMBOL(GE, $1));
        }
        | IN {
            $$ = alloc_NONTERMINAL(CL_relation, 18, 1, alloc_SYMBOL(IN, $1));
        }
        ;

SimpleConstExpr
        : ConstTerm_list {
            $$ = alloc_NONTERMINAL(CL_SimpleConstExpr, 19, 1, $1);
        }
        ;

ConstTerm_list
        : ConstTerm_list AddOperator ConstTerm {
            $$ = alloc_NONTERMINAL(CL_ConstTerm_list, 20, 3, $1, $2, $3);
        }
        | add_op_opt ConstTerm {
            $$ = alloc_NONTERMINAL(CL_ConstTerm_list, 21, 2, $1, $2);
        }
        ;

add_op_opt
        : '+' {
            $$ = alloc_NONTERMINAL(CL_add_op_opt, 22, 1, alloc_SYMBOL('+', $1));
        }
        | '-' {
            $$ = alloc_NONTERMINAL(CL_add_op_opt, 23, 1, alloc_SYMBOL('-', $1));
        }
        | /* empty */ {
            $$ = alloc_NONTERMINAL(CL_add_op_opt, 24, 0);
        }
        ;

AddOperator
        : '+' {
            $$ = alloc_NONTERMINAL(CL_AddOperator, 25, 1, alloc_SYMBOL('+', $1));
        }
        | '-' {
            $$ = alloc_NONTERMINAL(CL_AddOperator, 26, 1, alloc_SYMBOL('-', $1));
        }
        | OR {
            $$ = alloc_NONTERMINAL(CL_AddOperator, 27, 1, alloc_SYMBOL(OR, $1));
        }
        ;

ConstTerm
        : ConstTerm MulOperator ConstFactor {
            $$ = alloc_NONTERMINAL(CL_ConstTerm, 28, 3, $1, $2, $3);
        }
        | ConstFactor {
            $$ = alloc_NONTERMINAL(CL_ConstTerm, 29, 1, $1);
        }
        ;

MulOperator
        : '*' {
            $$ = alloc_NONTERMINAL(CL_MulOperator, 30, 1, alloc_SYMBOL('*', $1));
        }
        | '/' {
            $$ = alloc_NONTERMINAL(CL_MulOperator, 31, 1, alloc_SYMBOL('/', $1));
        }
        | DIV {
            $$ = alloc_NONTERMINAL(CL_MulOperator, 32, 1, alloc_SYMBOL(DIV, $1));
        }
        | MOD {
            $$ = alloc_NONTERMINAL(CL_MulOperator, 33, 1, alloc_SYMBOL(MOD, $1));
        }
        | AND {
            $$ = alloc_NONTERMINAL(CL_MulOperator, 34, 1, alloc_SYMBOL(AND, $1));
        }
        | '&' {
            $$ = alloc_NONTERMINAL(CL_MulOperator, 35, 1, alloc_SYMBOL('&', $1));
        } ;
ConstFactor
        : qualident {
            $$ = alloc_NONTERMINAL(CL_ConstFactor, 36, 1, $1);
        }
        | INTEGER {
            $$ = alloc_NONTERMINAL(CL_ConstFactor, 37, 1, alloc_INTEGER($1));
        }
        | REAL {
            $$ = alloc_NONTERMINAL(CL_ConstFactor, 38, 1, alloc_REAL($1));
        }
        | STRING {
            $$ = alloc_NONTERMINAL(CL_ConstFactor, 39, 1, alloc_STRING($1));
        }
        | CHARLIT {
            $$ = alloc_NONTERMINAL(CL_ConstFactor, 40, 1, alloc_CHARLIT($1));
        }
        | set {
            $$ = alloc_NONTERMINAL(CL_ConstFactor, 41, 1, $1);
        }
        | '(' ConstExpression ')' {
            $$ = alloc_NONTERMINAL(CL_ConstFactor, 42, 3, alloc_SYMBOL('(', $1), $2, alloc_SYMBOL(')', $3));
        }
        | NOT ConstFactor {
            $$ = alloc_NONTERMINAL(CL_ConstFactor, 43, 2, alloc_SYMBOL(NOT, $1), $2);
        }
        ;

set
        : qualident '{' element_list_opt '}' {
            $$ = alloc_NONTERMINAL(CL_ConstFactor, 44, 4, $1, alloc_SYMBOL('{', $2), $3, alloc_SYMBOL('}', $4));
        }
        | '{' element_list_opt '}' {
            $$ = alloc_NONTERMINAL(CL_ConstFactor, 45, 3, alloc_SYMBOL('{', $1), $2, alloc_SYMBOL('}', $3));
        }
        ;

element_list_opt
        : element_list {
            $$ = alloc_NONTERMINAL(CL_element_list_opt, 46, 1, $1);
        }
        | /* empty */ {
            $$ = alloc_NONTERMINAL(CL_element_list_opt, 47, 0);
        }
        ;

element_list
        : element_list ',' element {
            $$ = alloc_NONTERMINAL(CL_element_list, 48, 3, $1, alloc_SYMBOL(',', $2), $3);
        }
        | element {
            $$ = alloc_NONTERMINAL(CL_element_list, 49, 1, $1);
        }
        ;

element
        : ConstExpression RANGE ConstExpression {
            $$ = alloc_NONTERMINAL(CL_element, 50, 3, $1, alloc_SYMBOL(RANGE, $2), $3);
        }
        | ConstExpression  {
            $$ = alloc_NONTERMINAL(CL_element, 51, 1, $1);
        }
        ;


/* 6. Type declarations */

TypeDeclaration
        : IDENT '=' type {
            $$ = alloc_NONTERMINAL(CL_TypeDeclaration, 52, 3, alloc_IDENT($1), alloc_SYMBOL('=', $2), $3);
        }
        ;

type
        : SimpleType {
            $$ = alloc_NONTERMINAL(CL_type, 53, 1, $1);
        }
        | ArrayType {
            $$ = alloc_NONTERMINAL(CL_type, 54, 1, $1);
        }
        | RecordType {
            $$ = alloc_NONTERMINAL(CL_type, 55, 1, $1);
        }
        | SetType {
            $$ = alloc_NONTERMINAL(CL_type, 56, 1, $1);
        }
        | PointerType {
            $$ = alloc_NONTERMINAL(CL_type, 57, 1, $1);
        }
        | ProcedureType {
            $$ = alloc_NONTERMINAL(CL_type, 58, 1, $1);
        }
        ;

SimpleType
        : qualident {
            $$ = alloc_NONTERMINAL(CL_SimpleType, 59, 1, $1);
        }
        | enumeration {
            $$ = alloc_NONTERMINAL(CL_SimpleType, 60, 1, $1);
        }
        | SubrangeType {
            $$ = alloc_NONTERMINAL(CL_SimpleType, 61, 1, $1);
        }
        ;

/* 6.2. Enumerations */

enumeration
        : '(' IdentList ')' {
            $$ = alloc_NONTERMINAL(CL_enumeration, 62, 3, alloc_SYMBOL('(', $1), $2, alloc_SYMBOL(')', $3));
        }
        ;

IdentList
        : IdentList ',' IDENT {
            $$ = alloc_NONTERMINAL(CL_IdentList, 63, 3, $1, alloc_SYMBOL(',', $2), alloc_IDENT($3));
        }
        | IDENT {
            $$ = alloc_NONTERMINAL(CL_IdentList, 64, 1, alloc_IDENT($1));
        }
        ;

/* 6.3. Subrange types */

SubrangeType
        : '[' ConstExpression RANGE ConstExpression ']' {
            $$ = alloc_NONTERMINAL(CL_SubrangeType, 65, 5, alloc_SYMBOL('[', $1), $2, alloc_SYMBOL(RANGE, $3), $4, alloc_SYMBOL(']', $5));
        }
        ;

/* 6.4 Array types */

ArrayType
        : ARRAY SimpleType_list OF type {
            $$ = alloc_NONTERMINAL(CL_ArrayType, 66, 4, alloc_SYMBOL(ARRAY, $1), $2, alloc_SYMBOL(OF, $3), $4);
        }
        ;

SimpleType_list
        : SimpleType_list ',' SimpleType {
            $$ = alloc_NONTERMINAL(CL_SimpleType_list, 67, 3, $1, alloc_SYMBOL(',', $2), $3);
        }
        | SimpleType {
            $$ = alloc_NONTERMINAL(CL_SimpleType_list, 68, 1, $1);
        }
        ;

/* 6.5. Record types */

RecordType
        : RECORD
            FieldListSequence
          END {
            $$ = alloc_NONTERMINAL(CL_RecordType, 69, 3, alloc_SYMBOL(RECORD, $1), $2, alloc_SYMBOL(END, $3));
        }
        ;

FieldListSequence
        : FieldListSequence ';' FieldList {
            $$ = alloc_NONTERMINAL(CL_FieldListSequence, 70, 3, $1, alloc_SYMBOL(';', $2), $3);
        }
        | FieldList {
            $$ = alloc_NONTERMINAL(CL_FieldListSequence, 71, 1, $1);
        }
        ;

FieldList
        : IdentList ':' type {
            $$ = alloc_NONTERMINAL(CL_FieldList, 72, 3, $1, alloc_SYMBOL(':', $2), $3);
        }
        | CASE case_ident OF
                variant_list
                ELSE_FieldListSequence
          END {
            $$ = alloc_NONTERMINAL(CL_FieldList, 73, 6, alloc_SYMBOL(CASE, $1), $2, alloc_SYMBOL(OF, $3), $4, $5, alloc_SYMBOL(END, $6));
        }
        | /* empty */ {
            $$ = alloc_NONTERMINAL(CL_FieldList, 74, 0);
        }
        ;

case_ident
        : IDENT ':' qualident  {
            $$ = alloc_NONTERMINAL(CL_case_ident, 75, 3, alloc_IDENT($1), alloc_SYMBOL(':', $2), $3);
        }
        |           qualident {
            $$ = alloc_NONTERMINAL(CL_case_ident, 76, 1, $1);
        }
        ;

variant_list
        : variant_list '|' variant {
            $$ = alloc_NONTERMINAL(CL_variant_list, 77, 3, $1, alloc_SYMBOL('|', $2), $3);
        }
        | variant {
            $$ = alloc_NONTERMINAL(CL_variant_list, 78, 1, $1);
        }
        ;

ELSE_FieldListSequence
        : ELSE FieldListSequence {
            $$ = alloc_NONTERMINAL(CL_ELSE_FieldListSequence, 79, 2, alloc_SYMBOL(ELSE, $1), $2);
        }
        | /* empty */ {
            $$ = alloc_NONTERMINAL(CL_ELSE_FieldListSequence, 80, 0);
        }
        ;

variant
        : CaseLabelList ':' FieldListSequence {
            $$ = alloc_NONTERMINAL(CL_variant, 81, 3, $1, alloc_SYMBOL(':', $2), $3);
        }
        ;

CaseLabelList
        : CaseLabelList ',' CaseLabels {
            $$ = alloc_NONTERMINAL(CL_CaseLabelList, 82, 3, $1, alloc_SYMBOL(',', $2), $3);
        }
        | CaseLabels {
            $$ = alloc_NONTERMINAL(CL_CaseLabelList, 83, 1, $1);
        }
        ;

CaseLabels
        : ConstExpression RANGE ConstExpression {
            $$ = alloc_NONTERMINAL(CL_CaseLabels, 84, 3, $1, alloc_SYMBOL(RANGE, $2), $3);
        }
        | ConstExpression {
            $$ = alloc_NONTERMINAL(CL_CaseLabels, 85, 1, $1);
        }
        ;

/* 6.6. Set types */

SetType
        : SET OF SimpleType {
            $$ = alloc_NONTERMINAL(CL_SetType, 86, 3, alloc_SYMBOL(SET, $1), alloc_SYMBOL(OF, $2), $3);
        }
        ;

/* 6.7. Pointer types */

PointerType
        : POINTER TO type {
            $$ = alloc_NONTERMINAL(CL_PointerType, 87, 3, alloc_SYMBOL(POINTER, $1), alloc_SYMBOL(TO, $2), $3);
        }
        ;

/* 6.8 Procedure types */

ProcedureType
        : PROCEDURE FormalTypeList {
            $$ = alloc_NONTERMINAL(CL_ProcedureType, 88, 2, alloc_SYMBOL(PROCEDURE, $1), $2);
        }
        | PROCEDURE {
            $$ = alloc_NONTERMINAL(CL_ProcedureType, 89, 1, alloc_SYMBOL(PROCEDURE, $1));
        }
        ;

FormalTypeList
        : paren_formal_parameter_type_list_opt ':' qualident {
            $$ = alloc_NONTERMINAL(CL_FormalTypeList, 90, 3, $1, alloc_SYMBOL(':', $2), $3);
        }
        | paren_formal_parameter_type_list_opt {
            $$ = alloc_NONTERMINAL(CL_FormalTypeList, 91, 1, $1);
        }
        ;

paren_formal_parameter_type_list_opt
        : '(' formal_parameter_type_list_opt ')' {
            $$ = alloc_NONTERMINAL(CL_paren_formal_parameter_type_list_opt, 92, 3, alloc_SYMBOL('(', $1), $2, alloc_SYMBOL(')', $3));
        }
        ;

formal_parameter_type_list_opt
        : formal_parameter_type_list {
            $$ = alloc_NONTERMINAL(CL_formal_parameter_type_list_opt, 93, 1, $1);
        }
        | /* EMPTY */ {
            $$ = alloc_NONTERMINAL(CL_formal_parameter_type_list_opt, 94, 0);
        }
        ;

formal_parameter_type_list
        : formal_parameter_type_list ',' formal_parameter_type {
            $$ = alloc_NONTERMINAL(CL_formal_parameter_type_list, 95, 3, $1, alloc_SYMBOL(',', $2), $3);
        }
        | formal_parameter_type {
            $$ = alloc_NONTERMINAL(CL_formal_parameter_type_list, 96, 1, $1);
        }
        ;

formal_parameter_type
        : VAR FormalType {
            $$ = alloc_NONTERMINAL(CL_formal_parameter_type, 97, 2, alloc_SYMBOL(VAR, $1), $2);
        }
        | FormalType {
            $$ = alloc_NONTERMINAL(CL_formal_parameter_type, 98, 1, $1);
        }
        ;

VariableDeclaration
        : IdentList ':' type {
            $$ = alloc_NONTERMINAL(CL_VariableDeclaration, 99, 3, $1, alloc_SYMBOL(':', $2), $3);
        }
        ;

/* 8. Expressions */
/* 8.1. Operands */

designator
        : designator '.' IDENT {
            $$ = alloc_NONTERMINAL(CL_designator, 100, 3, $1, alloc_SYMBOL('.', $2), alloc_IDENT($3));
        }
        | designator '[' ExpList ']' {
            $$ = alloc_NONTERMINAL(CL_designator, 101, 4, $1, alloc_SYMBOL('[', $2), $3, alloc_SYMBOL(']', $4));
        }
        | designator '^' {
            $$ = alloc_NONTERMINAL(CL_designator, 102, 2, $1, alloc_SYMBOL('^', $2));
        }
        | qualident {
            $$ = alloc_NONTERMINAL(CL_designator, 103, 1, $1);
        }
        ;

ExpList
        : ExpList ',' expression {
            $$ = alloc_NONTERMINAL(CL_ExpList, 104, 3, $1, alloc_SYMBOL(',', $2), $3);
        }
        | expression {
            $$ = alloc_NONTERMINAL(CL_ExpList, 105, 1, $1);
        }
        ;

/* 8.2 Operators */

expression
        : SimpleExpression relation SimpleExpression {
            $$ = alloc_NONTERMINAL(CL_expression, 106, 3, $1, $2, $3);
        }
        | SimpleExpression {
            $$ = alloc_NONTERMINAL(CL_expression, 107, 1, $1);
        }
        ;

SimpleExpression
        : SimpleExpression AddOperator term {
            $$ = alloc_NONTERMINAL(CL_SimpleExpression, 108, 3, $1, $2, $3);
        }
        | add_op_opt term {
            $$ = alloc_NONTERMINAL(CL_SimpleExpression, 109, 2, $1, $2);
        }
        ;

term
        : term MulOperator factor {
            $$ = alloc_NONTERMINAL(CL_term, 110, 3, $1, $2, $3);
        }
        | factor {
            $$ = alloc_NONTERMINAL(CL_term, 111, 1, $1);
        }
        ;

factor
        : INTEGER {
            $$ = alloc_NONTERMINAL(CL_factor, 112, 1, alloc_INTEGER($1));
        }
        | REAL {
            $$ = alloc_NONTERMINAL(CL_factor, 113, 1, alloc_REAL($1));
        }
        | STRING {
            $$ = alloc_NONTERMINAL(CL_factor, 114, 1, alloc_STRING($1));
        }
        | CHARLIT {
            $$ = alloc_NONTERMINAL(CL_factor, 115, 1, alloc_CHARLIT($1));
        }
        | set {
            $$ = alloc_NONTERMINAL(CL_factor, 116, 1, $1);
        }
        | designator ActualParameters {
            $$ = alloc_NONTERMINAL(CL_factor, 117, 2, $1, $2);
        }
        | designator {
            $$ = alloc_NONTERMINAL(CL_factor, 118, 1, $1);
        }
        | '(' expression ')' {
            $$ = alloc_NONTERMINAL(CL_factor, 119, 3, alloc_SYMBOL('(', $1), $2, alloc_SYMBOL(')', $3));
        }
        | NOT factor {
            $$ = alloc_NONTERMINAL(CL_factor, 120, 2, alloc_SYMBOL(NOT, $1), $2);
        }
        ;

ActualParameters
        : '(' ExpList ')' {
            $$ = alloc_NONTERMINAL(CL_ActualParameters, 121, 3, alloc_SYMBOL('(', $1), $2, alloc_SYMBOL(')', $3));
        }
        | '(' ')' {
            $$ = alloc_NONTERMINAL(CL_ActualParameters, 122, 2, alloc_SYMBOL('(', $1), alloc_SYMBOL(')', $2));
        }
        ;

/* 9. Statements */

statement
        : assignment {
            $$ = alloc_NONTERMINAL(CL_statement, 123, 1, $1);
        }
        | ProcedureCall {
            $$ = alloc_NONTERMINAL(CL_statement, 124, 1, $1);
        }
        | IfStatement {
            $$ = alloc_NONTERMINAL(CL_statement, 125, 1, $1);
        }
        | CaseStatement {
            $$ = alloc_NONTERMINAL(CL_statement, 126, 1, $1);
        }
        | WhileStatement {
            $$ = alloc_NONTERMINAL(CL_statement, 127, 1, $1);
        }
        | RepeatStatement {
            $$ = alloc_NONTERMINAL(CL_statement, 128, 1, $1);
        }
        | LoopStatement {
            $$ = alloc_NONTERMINAL(CL_statement, 129, 1, $1);
        }
        | ForStatement {
            $$ = alloc_NONTERMINAL(CL_statement, 130, 1, $1);
        }
        | WithStatement {
            $$ = alloc_NONTERMINAL(CL_statement, 131, 1, $1);
        }
        | EXIT {
            $$ = alloc_NONTERMINAL(CL_statement, 132, 1, alloc_SYMBOL(EXIT, $1));
        }
        | TRETURN expression {
            $$ = alloc_NONTERMINAL(CL_statement, 133, 2, alloc_SYMBOL(TRETURN, $1), $2);
        }
        | TRETURN {
            $$ = alloc_NONTERMINAL(CL_statement, 134, 1, alloc_SYMBOL(TRETURN, $1));
        }
        | /* empty */ {
            $$ = alloc_NONTERMINAL(CL_statement, 135, 0);
        }
        ;

/* 9.1. Assignments */

assignment
        : designator ASSIGN expression {
            $$ = alloc_NONTERMINAL(CL_assignment, 136, 3, $1, alloc_SYMBOL(ASSIGN, $2), $3);
        }
        ;

/* 9.2. Procedure calls */

ProcedureCall
        : designator ActualParameters {
            $$ = alloc_NONTERMINAL(CL_ProcedureCall, 137, 2, $1, $2);
        }
        | designator {
            $$ = alloc_NONTERMINAL(CL_ProcedureCall, 138, 1, $1);
        }
        ;

/* 9.3. Statement sequences */

StatementSequence
        : StatementSequence ';' statement {
            $$ = alloc_NONTERMINAL(CL_StatementSequence, 139, 3, $1, alloc_SYMBOL(';', $2), $3);
        }
        | statement {
            $$ = alloc_NONTERMINAL(CL_StatementSequence, 140, 1, $1);
        }
        ;

/* 9.4. If statement */

IfStatement
        : IF expression THEN
            StatementSequence
          elsif_seq
          else_opt
          END {
            $$ = alloc_NONTERMINAL(CL_IfStatement, 141, 7, alloc_SYMBOL(IF, $1), $2, alloc_SYMBOL(THEN, $3), $4, $5, $6, alloc_SYMBOL(END, $7));
        }
        ;

elsif_seq
        : elsif_seq ELSIF expression THEN StatementSequence {
            $$ = alloc_NONTERMINAL(CL_elsif_seq, 142, 5, $1, alloc_SYMBOL(ELSIF, $2), $3, alloc_SYMBOL(THEN, $4), $5);
        }
        | /* EMPTY */ {
            $$ = alloc_NONTERMINAL(CL_elsif_seq, 143, 0);
        }
        ;

else_opt
        : ELSE StatementSequence {
            $$ = alloc_NONTERMINAL(CL_else_opt, 144, 2, alloc_SYMBOL(ELSE, $1), $2);
        }
        | /* EMPTY */ {
            $$ = alloc_NONTERMINAL(CL_else_opt, 145, 0);
        }
        ;

/* 9.5. Case statements */

CaseStatement
        : CASE expression OF
            case_list
            else_opt
          END {
            $$ = alloc_NONTERMINAL(CL_CaseStatement, 146, 6, alloc_SYMBOL(CASE, $1), $2, alloc_SYMBOL(OF, $3), $4, $5, alloc_SYMBOL(END, $6));
        }
        ;

case_list
        : case_list '|' case {
            $$ = alloc_NONTERMINAL(CL_case_list, 147, 3, $1, alloc_SYMBOL('|', $2), $3);
        }
        | case {
            $$ = alloc_NONTERMINAL(CL_case_list, 148, 1, $1);
        }
        ;

case
        : CaseLabelList ':' StatementSequence {
            $$ = alloc_NONTERMINAL(CL_case, 149, 3, $1, alloc_SYMBOL(':', $2), $3);
        }
        ;

/* 9.6. While statements */

WhileStatement
        : WHILE expression DO
            StatementSequence
          END {
            $$ = alloc_NONTERMINAL(CL_WhileStatement, 150, 5, alloc_SYMBOL(WHILE, $1), $2, alloc_SYMBOL(DO, $3), $4, alloc_SYMBOL(END, $5));
        }
        ;

/* 9.7. Repeat statements */

RepeatStatement
        : REPEAT
            StatementSequence
          UNTIL expression {
            $$ = alloc_NONTERMINAL(CL_RepeatStatement, 151, 4, alloc_SYMBOL(REPEAT, $1), $2, alloc_SYMBOL(UNTIL, $3), $4);
        }
        ;

/* 9.8. For statements */

ForStatement
        : FOR IDENT ASSIGN expression TO expression by_opt DO
            StatementSequence
          END {
            $$ = alloc_NONTERMINAL(CL_ForStatement, 152, 10, alloc_SYMBOL(FOR, $1), alloc_IDENT($2), alloc_SYMBOL(ASSIGN, $3),
            $4, alloc_SYMBOL(TO, $5), $6, $7, alloc_SYMBOL(DO, $8), $9, alloc_SYMBOL(END, $10));
        }
        ;

by_opt
        : BY ConstExpression {
            $$ = alloc_NONTERMINAL(CL_by_opt, 153, 2, alloc_SYMBOL(BY, $1), $2);
        }
        | /* empty */ {
            $$ = alloc_NONTERMINAL(CL_by_opt, 154, 0);
        }
        ;

/* 9.9. Loop statements */

LoopStatement
        : LOOP
            StatementSequence
          END {
            $$ = alloc_NONTERMINAL(CL_LoopStatement, 155, 3, alloc_SYMBOL(LOOP, $1), $2, alloc_SYMBOL(END, $3));
        }
        ;

/* 9.10. With statements */

WithStatement
        : WITH designator DO StatementSequence END {
            $$ = alloc_NONTERMINAL(CL_WithStatement, 156, 5, alloc_SYMBOL(WITH, $1), $2, alloc_SYMBOL(DO, $3), $4, alloc_SYMBOL(END, $3));
        }
        ;

/* 10. Procedure declarations */

ProcedureDeclaration
        : ProcedureHeading ';' block IDENT {
            $$ = alloc_NONTERMINAL(CL_ProcedureDeclaration, 157, 4, $1, alloc_SYMBOL(';', $2), $3, alloc_IDENT($4));
        }
        ;

ProcedureHeading
        : PROCEDURE IDENT FormalParameters_opt {
            $$ = alloc_NONTERMINAL(CL_ProcedureHeading, 158, 3, alloc_SYMBOL(PROCEDURE, $1), alloc_IDENT($2), $3);
        }
        ;

FormalParameters_opt
        : FormalParameters {
            $$ = alloc_NONTERMINAL(CL_FormalParameters_opt, 159, 1, $1);
        }
        | /* empty */ {
            $$ = alloc_NONTERMINAL(CL_FormalParameters_opt, 160, 0);
        }
        ;

block
        : declaration_list_opt
          BEGIN_StatementSequence_opt
          END {
            $$ = alloc_NONTERMINAL(CL_block, 161, 3, $1, $2, alloc_SYMBOL(END, $3));
        }
        ;

declaration_list_opt
        : declaration_list_opt declaration {
            $$ = alloc_NONTERMINAL(CL_declaration_list_opt, 162, 2, $1, $2);
        }
        | /* empty */ {
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
            $$ = alloc_NONTERMINAL(CL_declaration_list_opt, 163, 0);
        }
        ;

BEGIN_StatementSequence_opt
        : TBEGIN StatementSequence {
            $$ = alloc_NONTERMINAL(CL_BEGIN_StatementSequence_opt, 164, 2, alloc_SYMBOL(TBEGIN, $1), $2);
        }
        | /* empty */ {
            $$ = alloc_NONTERMINAL(CL_BEGIN_StatementSequence_opt, 165, 0);
        }
        ;

declaration
        : CONST ConstantDeclaration_list_opt {
            $$ = alloc_NONTERMINAL(CL_declaration, 166, 2, alloc_SYMBOL(CONST, $1), $2);
        }
        | TYPE TypeDeclaration_list_opt {
            $$ = alloc_NONTERMINAL(CL_declaration, 167, 2, alloc_SYMBOL(TYPE, $1), $2);
        }
        | VAR VariableDeclaration_list_opt {
            $$ = alloc_NONTERMINAL(CL_declaration, 168, 2, alloc_SYMBOL(VAR, $1), $2);
        }
        | ProcedureDeclaration ';' {
            $$ = alloc_NONTERMINAL(CL_declaration, 169, 2, $1, alloc_SYMBOL(';', $2));
        }
        | ModuleDeclaration ';' {
            $$ = alloc_NONTERMINAL(CL_declaration, 170, 2, $1, alloc_SYMBOL(';', $2));
        }
        ;

ConstantDeclaration_list_opt
        : ConstantDeclaration_list_opt ConstantDeclaration ';' {
            $$ = alloc_NONTERMINAL(CL_ConstantDeclaration_list_opt, 171, 3, $1, $2, alloc_SYMBOL(';', $3));
        }
        | /* empty */ {
            $$ = alloc_NONTERMINAL(CL_ConstantDeclaration_list_opt, 172, 0);
        }
        ;

TypeDeclaration_list_opt
        : TypeDeclaration_list_opt TypeDeclaration ';' {
            $$ = alloc_NONTERMINAL(CL_TypeDeclaration_list_opt, 173, 3, $1, $2, alloc_SYMBOL(';', $3));
        }
        | /* empty */ {
            $$ = alloc_NONTERMINAL(CL_TypeDeclaration_list_opt, 174, 0);
        }
        ;

VariableDeclaration_list_opt
        : VariableDeclaration_list_opt VariableDeclaration ';' {
            $$ = alloc_NONTERMINAL(CL_VariableDeclaration_list_opt, 175, 3, $1, $2, alloc_SYMBOL(';', $3));
        }
        | /* empty */ {
            $$ = alloc_NONTERMINAL(CL_VariableDeclaration_list_opt, 176, 0);
        }
        ;

/* 10.1. Formal parameters */

FormalParameters
        : '(' FPSection_list_opt ')' ':' qualident {
            $$ = alloc_NONTERMINAL(CL_FormalParameters, 177, 5, alloc_SYMBOL('(', $1), $2, alloc_SYMBOL(')', $3), alloc_SYMBOL(':', $4), $5);
        }
        | '(' FPSection_list_opt ')' {
            $$ = alloc_NONTERMINAL(CL_FormalParameters, 178, 3, alloc_SYMBOL('(', $1), $2, alloc_SYMBOL(')', $3));
        }
        ;

FPSection_list_opt
        : FPSection_list {
            $$ = alloc_NONTERMINAL(CL_FPSection_list_opt, 179, 1, $1);
        }
        | /* empty */ {
            $$ = alloc_NONTERMINAL(CL_FPSection_list_opt, 180, 0);
        }
        ;

FPSection_list
        : FPSection_list ';' FPSection {
            $$ = alloc_NONTERMINAL(CL_FPSection_list, 181, 3, $1, alloc_SYMBOL(';', $2), $3);
        }
        | FPSection {
            $$ = alloc_NONTERMINAL(CL_FPSection_list, 182, 1, $1);
        }
        ;

FPSection
        : VAR IdentList ':' FormalType {
            $$ = alloc_NONTERMINAL(CL_FPSection, 183, 4, alloc_SYMBOL(VAR, $1), $2, alloc_SYMBOL(':', $3), $4);
        }
        |     IdentList ':' FormalType {
            $$ = alloc_NONTERMINAL(CL_FPSection, 184, 3, $1, alloc_SYMBOL(':', $2), $3);
        }
        ;

FormalType
        : ARRAY OF qualident {
            $$ = alloc_NONTERMINAL(CL_FormalType, 185, 3, alloc_SYMBOL(ARRAY, $1), alloc_SYMBOL(OF, $2), $3);
        }
        | qualident {
            $$ = alloc_NONTERMINAL(CL_FormalType, 186, 1, $1);
        }
        ;

/* 11. Modules */

ModuleDeclaration
        : MODULE IDENT priority_opt ';'
            import_list_opt
            export_opt
          block IDENT {
            $$ = alloc_NONTERMINAL(CL_ModuleDeclaration, 187, 8, alloc_SYMBOL(MODULE, $1), alloc_IDENT($2), $3,
            alloc_SYMBOL(';', $4), $5, $6, $7, alloc_IDENT($8));
        }
        ;

priority_opt
        : '[' ConstExpression ']' {
            $$ = alloc_NONTERMINAL(CL_priority_opt, 188, 3, alloc_SYMBOL('[', $1), $2, alloc_SYMBOL(']', $3));
        }
        | /* empty */ {
            $$ = alloc_NONTERMINAL(CL_priority_opt, 189, 0);
        }
        ;

import_list_opt
        : import_list_opt import {
            $$ = alloc_NONTERMINAL(CL_import_list_opt, 190, 2, $1, $2);
        }
        | /* empty */ {
            $$ = alloc_NONTERMINAL(CL_import_list_opt, 191, 0);
        }
        ;

export_opt
        : EXPORT QUALIFIED IdentList ';' {
            $$ = alloc_NONTERMINAL(CL_export_opt, 192, 4, alloc_SYMBOL(EXPORT, $1), alloc_SYMBOL(QUALIFIED, $2), $3, alloc_SYMBOL(';', $4));
        }
        | EXPORT IdentList ';' {
            $$ = alloc_NONTERMINAL(CL_export_opt, 193, 3, alloc_SYMBOL(EXPORT, $1), $2, alloc_SYMBOL(';', $3));
        }
        | /* empty */ {
            $$ = alloc_NONTERMINAL(CL_export_opt, 194, 0);
        }
        ;

import
        : FROM IDENT IMPORT IdentList ';' {
            $$ = alloc_NONTERMINAL(CL_import, 195, 5, alloc_SYMBOL(FROM, $1), alloc_IDENT($2),
                    alloc_SYMBOL(IMPORT, $3), $4, alloc_SYMBOL(';', $5));
        }
        |        IMPORT IdentList ';' {
            $$ = alloc_NONTERMINAL(CL_import, 196, 3, alloc_SYMBOL(IMPORT, $1), $2, alloc_SYMBOL(';', $3));
        }
        ;

/* 14. Compilation Units */

DefinitionModule
        : DEFINITION MODULE IDENT ';'
            import_list_opt
            export_opt
            definition_list_opt
          END IDENT {
            $$ = alloc_NONTERMINAL(CL_DefinitionModule, 197, 9, alloc_SYMBOL(DEFINITION, $1), alloc_SYMBOL(MODULE, $2),
                alloc_IDENT($3), alloc_SYMBOL(';', $4), $5, $6, $7, alloc_SYMBOL(END, $8), alloc_IDENT($9));
        }
        ;

definition_list_opt
        : definition_list_opt definition {
            $$ = alloc_NONTERMINAL(CL_definition_list_opt, 198, 2, $1, $2);
        }
        | /* empty */ {
            $$ = alloc_NONTERMINAL(CL_definition_list_opt, 199, 0);
        }
        ;

definition
        : CONST ConstantDeclaration_list_opt {
            $$ = alloc_NONTERMINAL(CL_definition, 200, 2, alloc_SYMBOL(CONST, $1), $2);
        }
        | TYPE opaque_type_list_opt {
            $$ = alloc_NONTERMINAL(CL_definition, 201, 2, alloc_SYMBOL(TYPE, $1), $2);
        }
        | VAR VariableDeclaration_list_opt {
            $$ = alloc_NONTERMINAL(CL_definition, 202, 2, alloc_SYMBOL(VAR, $1), $2);
        }
        | ProcedureHeading ';' {
            $$ = alloc_NONTERMINAL(CL_definition, 203, 2, $1, alloc_SYMBOL(';', $2));
        }
        ;

opaque_type_list_opt
        : opaque_type_list_opt opaque_type {
            $$ = alloc_NONTERMINAL(CL_opaque_type_list_opt, 204, 2, $1, $2);
        }
        | /* empty */ {
            $$ = alloc_NONTERMINAL(CL_opaque_type_list_opt, 205, 0);
        }
        ;

opaque_type
        : IDENT '=' type ';' {
            $$ = alloc_NONTERMINAL(CL_opaque_type, 206, 4, alloc_IDENT($1), alloc_SYMBOL('=', $2), $3, alloc_SYMBOL(';', $4));
        }
        | IDENT ';' {
            $$ = alloc_NONTERMINAL(CL_opaque_type, 207, 2, alloc_IDENT($1), alloc_SYMBOL(';', $2));
        }
        ;

ProgramModule
        : MODULE IDENT priority_opt ';'
            import_list_opt
          block IDENT {
            $$ = alloc_NONTERMINAL(CL_ProgramModule, 208, 7, alloc_SYMBOL(MODULE, $1), alloc_IDENT($2), $3,
            alloc_SYMBOL(';', $4), $5, $6, alloc_IDENT($7));
        }
        ;

%%

int main(int argc, char **argv)
{
    if (global_config(argc, argv))
        ERROR("global_config failed");
    yyparse();
    return 0;
}

int yyerror(char *msg)
{
    printf(F("Error: %s\n"), msg);
    return 0;
}
