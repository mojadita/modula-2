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
#error please, define USE_COLOR to compile this source.
#endif

#ifndef DEBUG
#define DEBUG 0
#endif /* DEBUG */

#if defined(YYBISON) && YYBISON
#define RULENUM yyn-1
#else
#define RULENUM yyn
#endif

#if DEBUG
#if USE_COLOR
#define C(n) "\033["n"m"
#else /* USE_COLOR */
#define C(n)
#define QUOTE(x) C("37")"<" x C("37")">"
#define LEFT(nt) QUOTE(#nt)
#define TERMIN(t) " "C("34") t
#define NONTERM(s) " "QUOTE(C("32") #s)
#define SYMBOL(op) " "C("31")"'" op "'"
#define KEYWORD(k) " "C("37") #k
#define EMPTY " "C("34")"/* EMPTY */"
#define RULE(lft, rgt, ...) do{ \
        printf(F(C("37")"R-%03d: "\
            C("37") "<" C("36") #lft C("37") ">"\
            C("33") " ::=" rgt C("33") "." C() "\n"),\
            RULENUM,##__VA_ARGS__); \
        }while(0)
#endif /* USE_COLOR */
#else /* DEBUG */
#define RULE(...) /* empty */
#endif /* DEBUG */

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
    const char         *string;
    int                 integer;
    double              real;
    union tree_node     nonterm;
}

%% 

CompilationUnit
        : DefinitionModule '.' {
            $$ = alloc_NONTERMINAL(CL_CompilationUnit, 1, 2, $1, alloc_SYMBOL('.', $2));
                RULE(CompilationUnit, NONTERM(DefinitionModule) SYMBOL("."));
            if (global.flags & GL_FLAG_VERBOSE_PARSE_TREE)
            print_subtree($$, stdout, ROOT_NODE);
        }
        | IMPLEMENTATION ProgramModule '.' {
            $$ = alloc_NONTERMINAL(CL_CompilationUnit, 2, 3, alloc_SYMBOL(IMPLEMENTATION, $1), $2, alloc_SYMBOL('.', $3));
                RULE(CompilationUnit, KEYWORD(IMPLEMENTATION) NONTERM(ProgramModule) SYMBOL("."));
            if (global.flags & GL_FLAG_VERBOSE_PARSE_TREE)
            print_subtree($$, stdout, ROOT_NODE);
        }
        | ProgramModule '.' {
            $$ = alloc_NONTERMINAL(CL_CompilationUnit, 3, 2, $1, alloc_SYMBOL('.', $2));
                RULE(CompilationUnit, NONTERM(ProgramModule) SYMBOL("."));
            if (global.flags & GL_FLAG_VERBOSE_PARSE_TREE)
            print_subtree($$, stdout, ROOT_NODE);
        }
        ;

qualident
        : qualifier '.' IDENT {
            $$ = alloc_NONTERMINAL(CL_qualident, 4, 3, $1, alloc_SYMBOL('.', $2), alloc_IDENT($3));
            RULE(qualident, NONTERM(qualifier) SYMBOL(".") TERMIN("IDENT:%s"), $3);
        }
        | IDENT {
            $$ = alloc_NONTERMINAL(CL_qualident, 5, 1, alloc_IDENT($1));
            RULE(qualident, TERMIN("IDENT:%s"), $1);
        }
        ;

qualifier
        : qualifier '.' MOD_IDENT {
            $$ = alloc_NONTERMINAL(CL_qualifier, 6, 3, $1, alloc_SYMBOL('.', $2), alloc_MOD_IDENT($3));
            RULE(qualifier, NONTERM(qualifier) SYMBOL(".") TERMIN("MOD_IDENT"));
        }
        | MOD_IDENT {
            $$ = alloc_NONTERMINAL(CL_qualifier, 7, 1, alloc_MOD_IDENT($1));
            RULE(qualifier, TERMIN("MOD_IDENT"));
        }
        ;

/* 5. Constant declarations */

ConstantDeclaration
        : IDENT '=' ConstExpression {
            $$ = alloc_NONTERMINAL(CL_ConstantDeclaration, 8, 3, alloc_IDENT($1), alloc_SYMBOL('=', $2), $3);
            RULE(ConstantDeclaration, TERMIN("IDENT:%s") SYMBOL("=") NONTERM(ConstExpression), $1);
        }
        ;

ConstExpression
        : SimpleConstExpr relation SimpleConstExpr {
            $$ = alloc_NONTERMINAL(CL_ConstExpression, 9, 3, $1, $2, $3);
            RULE(ConstExpression, NONTERM(SimpleConstExpr) NONTERM(relation) NONTERM(SimpleConstExpr));
        }
        | SimpleConstExpr {
            $$ = alloc_NONTERMINAL(CL_ConstExpression, 10, 1, $1);
            RULE(ConstExpression, NONTERM(SimpleConstExpr));
        }
        ;

relation
        : '=' {
            $$ = alloc_NONTERMINAL(CL_relation, 11, 1, alloc_SYMBOL('=', $1));
            RULE(relation, SYMBOL("="));
        }
        | '#' {
            $$ = alloc_NONTERMINAL(CL_relation, 12, 1, alloc_SYMBOL('#', $1));
            RULE(relation, SYMBOL("#"));
        }
        | NE {
            $$ = alloc_NONTERMINAL(CL_relation, 13, 1, alloc_SYMBOL(NE, $1));
            RULE(relation, SYMBOL("<>"));
        }
        | '<' {
            $$ = alloc_NONTERMINAL(CL_relation, 14, 1, alloc_SYMBOL('<', $1));
            RULE(relation, SYMBOL("<"));
        }
        | LE {
            $$ = alloc_NONTERMINAL(CL_relation, 15, 1, alloc_SYMBOL(LE, $1));
            RULE(relation, SYMBOL("<="));
        }
        | '>' {
            $$ = alloc_NONTERMINAL(CL_relation, 16, 1, alloc_SYMBOL('>', $1));
            RULE(relation, SYMBOL(">"));
        }
        | GE {
            $$ = alloc_NONTERMINAL(CL_relation, 17, 1, alloc_SYMBOL(GE, $1));
            RULE(relation, SYMBOL(">="));
        }
        | IN {
            $$ = alloc_NONTERMINAL(CL_relation, 18, 1, alloc_SYMBOL(IN, $1));
            RULE(relation, KEYWORD(IN));
        }
        ;

SimpleConstExpr
        : ConstTerm_list {
            $$ = alloc_NONTERMINAL(CL_SimpleConstExpr, 19, 1, $1);
            RULE(SimpleConstExpr, NONTERM(ConstTerm_list));
        }
        ;

ConstTerm_list
        : ConstTerm_list AddOperator ConstTerm {
            $$ = alloc_NONTERMINAL(CL_ConstTerm_list, 20, 3, $1, $2, $3);
            RULE(ConstTerm_list, NONTERM(ConstTerm_list) NONTERM(AddOperator) NONTERM(ConstTerm));
        }
        | add_op_opt ConstTerm {
            $$ = alloc_NONTERMINAL(CL_ConstTerm_list, 21, 2, $1, $2);
            RULE(ConstTerm_list, NONTERM(add_op_opt) NONTERM(ConstTerm));
        }
        ;

add_op_opt
        : '+' {
            $$ = alloc_NONTERMINAL(CL_add_op_opt, 22, 1, alloc_SYMBOL('+', $1));
            RULE(add_op_opt, SYMBOL("+"));
        }
        | '-' {
            $$ = alloc_NONTERMINAL(CL_add_op_opt, 23, 1, alloc_SYMBOL('-', $1));
            RULE(add_op_opt, SYMBOL("-"));
        }
        | /* empty */ {
            $$ = alloc_NONTERMINAL(CL_add_op_opt, 24, 0);
            RULE(add_op_opt, EMPTY);
        }
        ;

AddOperator
        : '+' {
            $$ = alloc_NONTERMINAL(CL_AddOperator, 25, 1, alloc_SYMBOL('+', $1));
            RULE(AddOperator, SYMBOL("+"));
        }
        | '-' {
            $$ = alloc_NONTERMINAL(CL_AddOperator, 26, 1, alloc_SYMBOL('-', $1));
            RULE(AddOperator, SYMBOL("-"));
        }
        | OR {
            $$ = alloc_NONTERMINAL(CL_AddOperator, 27, 1, alloc_SYMBOL(OR, $1));
            RULE(AddOperator, KEYWORD(OR));
        }
        ;

ConstTerm
        : ConstTerm MulOperator ConstFactor {
            $$ = alloc_NONTERMINAL(CL_ConstTerm, 28, 3, $1, $2, $3);
            RULE(ConstTerm, NONTERM(ConstTerm) NONTERM(MulOperator) NONTERM(ConstFactor));
        }
        | ConstFactor {
            $$ = alloc_NONTERMINAL(CL_ConstTerm, 29, 1, $1);
            RULE(ConstTerm, NONTERM(ConstFactor));
        }
        ;

MulOperator
        : '*' {
            $$ = alloc_NONTERMINAL(CL_MulOperator, 30, 1, alloc_SYMBOL('*', $1));
            RULE(MulOperator, SYMBOL("*"));
        }
        | '/' {
            $$ = alloc_NONTERMINAL(CL_MulOperator, 31, 1, alloc_SYMBOL('/', $1));
            RULE(MulOperator, SYMBOL("/"));
        }
        | DIV {
            $$ = alloc_NONTERMINAL(CL_MulOperator, 32, 1, alloc_SYMBOL(DIV, $1));
            RULE(MulOperator, KEYWORD(DIV));
        }
        | MOD {
            $$ = alloc_NONTERMINAL(CL_MulOperator, 33, 1, alloc_SYMBOL(MOD, $1));
            RULE(MulOperator, KEYWORD(MOD));
        }
        | AND {
            $$ = alloc_NONTERMINAL(CL_MulOperator, 34, 1, alloc_SYMBOL(AND, $1));
            RULE(MulOperator, KEYWORD(AND));
        }
        | '&' {
            $$ = alloc_NONTERMINAL(CL_MulOperator, 35, 1, alloc_SYMBOL('&', $1));
            RULE(MulOperator, SYMBOL("&"));
        } ;
ConstFactor
        : qualident {
            $$ = alloc_NONTERMINAL(CL_ConstFactor, 36, 1, $1);
            RULE(ConstFactor, NONTERM(qualident));
        }
        | INTEGER {
            $$ = alloc_NONTERMINAL(CL_ConstFactor, 37, 1, alloc_INTEGER($1));
            RULE(ConstFactor, TERMIN("INTEGER(%d)"), $1);
        }
        | REAL {
            $$ = alloc_NONTERMINAL(CL_ConstFactor, 38, 1, alloc_REAL($1));
            RULE(ConstFactor, TERMIN("REAL(%lg)"), $1);
        }
        | STRING {
            $$ = alloc_NONTERMINAL(CL_ConstFactor, 39, 1, alloc_STRING($1));
            RULE(ConstFactor, TERMIN("STRING(%s)"), $1);
        }
        | CHARLIT {
            $$ = alloc_NONTERMINAL(CL_ConstFactor, 40, 1, alloc_CHARLIT($1));
            RULE(ConstFactor, TERMIN("CHARLIT(\\%03d)"), $1);
        }
        | set {
            $$ = alloc_NONTERMINAL(CL_ConstFactor, 41, 1, $1);
            RULE(ConstFactor, NONTERM(set));
        }
        | '(' ConstExpression ')' {
            $$ = alloc_NONTERMINAL(CL_ConstFactor, 42, 3, alloc_SYMBOL('(', $1), $2, alloc_SYMBOL(')', $3));
            RULE(ConstFactor, SYMBOL("(") NONTERM(ConstExpression) SYMBOL(")"));
        }
        | NOT ConstFactor {
            $$ = alloc_NONTERMINAL(CL_ConstFactor, 43, 2, alloc_SYMBOL(NOT, $1), $2);
            RULE(ConstFactor, KEYWORD(NOT) NONTERM(ConstFactor));
        }
        ;

set
        : qualident '{' element_list_opt '}' {
            $$ = alloc_NONTERMINAL(CL_ConstFactor, 44, 4, $1, alloc_SYMBOL('{', $2), $3, alloc_SYMBOL('}', $4));
            RULE(set, NONTERM(qualident) SYMBOL("{") NONTERM(element_list_opt) SYMBOL("}"));
        }
        | '{' element_list_opt '}' {
            $$ = alloc_NONTERMINAL(CL_ConstFactor, 45, 3, alloc_SYMBOL('{', $1), $2, alloc_SYMBOL('}', $3));
            RULE(set, SYMBOL("{") NONTERM(element_list_opt) SYMBOL("}"));
        }
        ;

element_list_opt
        : element_list {
            $$ = alloc_NONTERMINAL(CL_element_list_opt, 46, 1, $1);
            RULE(element_list_opt, NONTERM(element_list));
        }
        | /* empty */ {
            $$ = alloc_NONTERMINAL(CL_element_list_opt, 47, 0);
            RULE(element_list_opt, EMPTY);
        }
        ;

element_list
        : element_list ',' element {
            $$ = alloc_NONTERMINAL(CL_element_list, 48, 3, $1, alloc_SYMBOL(',', $2), $3);
            RULE(element_list, NONTERM(element_list) SYMBOL(",") NONTERM(element));
        }
        | element {
            $$ = alloc_NONTERMINAL(CL_element_list, 49, 1, $1);
            RULE(element_list, NONTERM(element));
        }
        ;

element
        : ConstExpression RANGE ConstExpression {
            $$ = alloc_NONTERMINAL(CL_element, 50, 3, $1, alloc_SYMBOL(RANGE, $2), $3);
            RULE(element, NONTERM(ConstExpression) SYMBOL("..") NONTERM(ConstExpression));
        }
        | ConstExpression  {
            $$ = alloc_NONTERMINAL(CL_element, 51, 1, $1);
            RULE(element, NONTERM(ConstExpression));
        }
        ;


/* 6. Type declarations */

TypeDeclaration
        : IDENT '=' type {
            $$ = alloc_NONTERMINAL(CL_TypeDeclaration, 52, 3, alloc_IDENT($1), alloc_SYMBOL('=', $2), $3);
                RULE(TypeDeclaration, TERMIN("IDENT:%s") SYMBOL("=") NONTERM(type), $1);
        }
        ;

type
        : SimpleType {
            $$ = alloc_NONTERMINAL(CL_type, 53, 1, $1);
                RULE(type, NONTERM(SimpleType));
        }
        | ArrayType {
            $$ = alloc_NONTERMINAL(CL_type, 54, 1, $1);
                RULE(type, NONTERM(ArrayType));
        }
        | RecordType {
            $$ = alloc_NONTERMINAL(CL_type, 55, 1, $1);
                RULE(type, NONTERM(RecordType));
        }
        | SetType {
            $$ = alloc_NONTERMINAL(CL_type, 56, 1, $1);
                RULE(type, NONTERM(SetType));
        }
        | PointerType {
            $$ = alloc_NONTERMINAL(CL_type, 57, 1, $1);
                RULE(type, NONTERM(PointerType));
        }
        | ProcedureType {
            $$ = alloc_NONTERMINAL(CL_type, 58, 1, $1);
                RULE(type, NONTERM(ProcedureType));
        }
        ;

SimpleType
        : qualident {
            $$ = alloc_NONTERMINAL(CL_SimpleType, 59, 1, $1);
                RULE(SimpleType, NONTERM(qualident));
        }
        | enumeration {
            $$ = alloc_NONTERMINAL(CL_SimpleType, 60, 1, $1);
                RULE(SimpleType, NONTERM(enumeration));
        }
        | SubrangeType {
            $$ = alloc_NONTERMINAL(CL_SimpleType, 61, 1, $1);
                RULE(SimpleType, NONTERM(SubrangeType));
        }
        ;

/* 6.2. Enumerations */

enumeration
        : '(' IdentList ')' {
            $$ = alloc_NONTERMINAL(CL_enumeration, 62, 3, alloc_SYMBOL('(', $1), $2, alloc_SYMBOL(')', $3));
                RULE(enumeration, SYMBOL("(") NONTERM(IdentList) SYMBOL(")"));
        }
        ;

IdentList
        : IdentList ',' IDENT {
            $$ = alloc_NONTERMINAL(CL_IdentList, 63, 3, $1, alloc_SYMBOL(',', $2), alloc_IDENT($3));
                RULE(IdentList, NONTERM(IdentList) SYMBOL(",") TERMIN("IDENT:%s"), $3);
        }
        | IDENT {
            $$ = alloc_NONTERMINAL(CL_IdentList, 64, 1, alloc_IDENT($1));
                RULE(IdentList, TERMIN("IDENT:%s"), $1);
        }
        ;

/* 6.3. Subrange types */

SubrangeType
        : '[' ConstExpression RANGE ConstExpression ']' {
            $$ = alloc_NONTERMINAL(CL_SubrangeType, 65, 5, alloc_SYMBOL('[', $1), $2, alloc_SYMBOL(RANGE, $3), $4, alloc_SYMBOL(']', $5));
                RULE(SubrangeType, SYMBOL("[") NONTERM(ConstExpression) SYMBOL("..") NONTERM(ConstExpression));
        }
        ;

/* 6.4 Array types */

ArrayType
        : ARRAY SimpleType_list OF type {
            $$ = alloc_NONTERMINAL(CL_ArrayType, 66, 4, alloc_SYMBOL(ARRAY, $1), $2, alloc_SYMBOL(OF, $3), $4);
                RULE(ArrayType, KEYWORD(ARRAY) NONTERM(SimpleType_list) KEYWORD(OF) NONTERM(type));
        }
        ;

SimpleType_list
        : SimpleType_list ',' SimpleType {
            $$ = alloc_NONTERMINAL(CL_SimpleType_list, 67, 3, $1, alloc_SYMBOL(',', $2), $3);
                RULE(SimpleType_list, NONTERM(SimpleType_list) SYMBOL(",") NONTERM(SimpleType));
        }
        | SimpleType {
            $$ = alloc_NONTERMINAL(CL_SimpleType_list, 68, 1, $1);
                RULE(SimpleType_list, NONTERM(SimpleType));
        }
        ;

/* 6.5. Record types */

RecordType
        : RECORD
            FieldListSequence
          END {
            $$ = alloc_NONTERMINAL(CL_RecordType, 69, 3, alloc_SYMBOL(RECORD, $1), $2, alloc_SYMBOL(END, $3));
                RULE(RECORD, KEYWORD(RECORD) NONTERM(FieldListSequence) KEYWORD(END));
        }
        ;

FieldListSequence
        : FieldListSequence ';' FieldList {
            $$ = alloc_NONTERMINAL(CL_FieldListSequence, 70, 3, $1, alloc_SYMBOL(';', $2), $3);
                RULE(FieldListSequence, NONTERM(FieldListSequence) SYMBOL(";") NONTERM(FieldList));
        }
        | FieldList {
            $$ = alloc_NONTERMINAL(CL_FieldListSequence, 71, 1, $1);
                RULE(FieldListSequence, NONTERM(FieldList));
        }
        ;

FieldList
        : IdentList ':' type {
            $$ = alloc_NONTERMINAL(CL_FieldList, 72, 3, $1, alloc_SYMBOL(':', $2), $3);
                RULE(FieldList, NONTERM(IdentList) SYMBOL(":") NONTERM(type));
        }
        | CASE case_ident OF
                variant_list
                ELSE_FieldListSequence
          END {
            $$ = alloc_NONTERMINAL(CL_FieldList, 73, 6, alloc_SYMBOL(CASE, $1), $2, alloc_SYMBOL(OF, $3), $4, $5, alloc_SYMBOL(END, $6));
                RULE(FieldList, KEYWORD(CASE) NONTERM(case_ident) KEYWORD(OF)
                    NONTERM(variant_list) NONTERM(ELSE_FieldListSequence) KEYWORD(END));
        }
        | /* empty */ {
            $$ = alloc_NONTERMINAL(CL_FieldList, 74, 0);
                RULE(FieldList, EMPTY);
        }
        ;

case_ident
        : IDENT ':' qualident  {
            $$ = alloc_NONTERMINAL(CL_case_ident, 75, 3, alloc_IDENT($1), alloc_SYMBOL(':', $2), $3);
                RULE(case_ident, TERMIN("IDENT:%s") SYMBOL(":") NONTERM(qualident), $1);
        }
        |           qualident {
            $$ = alloc_NONTERMINAL(CL_case_ident, 76, 1, $1);
                RULE(case_ident, NONTERM(qualident));
        }
        ;

variant_list
        : variant_list '|' variant {
            $$ = alloc_NONTERMINAL(CL_variant_list, 77, 3, $1, alloc_SYMBOL('|', $2), $3);
                RULE(variant_list, NONTERM(variant_list) SYMBOL("|") NONTERM(variant));
        }
        | variant {
            $$ = alloc_NONTERMINAL(CL_variant_list, 78, 1, $1);
                RULE(variant_list, NONTERM(variant));
        }
        ;

ELSE_FieldListSequence
        : ELSE FieldListSequence {
            $$ = alloc_NONTERMINAL(CL_ELSE_FieldListSequence, 79, 2, alloc_SYMBOL(ELSE, $1), $2);
                RULE(ELSE_FieldListSequence, KEYWORD(ELSE) NONTERM(FieldListSequence));
        }
        | /* empty */ {
            $$ = alloc_NONTERMINAL(CL_ELSE_FieldListSequence, 80, 0);
                RULE(ELSE_FieldListSequence, EMPTY);
        }
        ;

variant
        : CaseLabelList ':' FieldListSequence {
            $$ = alloc_NONTERMINAL(CL_variant, 81, 3, $1, alloc_SYMBOL(':', $2), $3);
                RULE(variant, NONTERM(CaseLabelList) SYMBOL(":") NONTERM(FieldListSequence));
        }
        ;

CaseLabelList
        : CaseLabelList ',' CaseLabels {
            $$ = alloc_NONTERMINAL(CL_CaseLabelList, 82, 3, $1, alloc_SYMBOL(',', $2), $3);
                RULE(CaseLabelList, NONTERM(CaseLabelList) SYMBOL(",") NONTERM(CaseLabels));
        }
        | CaseLabels {
            $$ = alloc_NONTERMINAL(CL_CaseLabelList, 83, 1, $1);
                RULE(CaseLabelList, NONTERM(CaseLabels));
        }
        ;

CaseLabels
        : ConstExpression RANGE ConstExpression {
            $$ = alloc_NONTERMINAL(CL_CaseLabels, 84, 3, $1, alloc_SYMBOL(RANGE, $2), $3);
                RULE(CaseLabels, NONTERM(ConstExpression) SYMBOL("..") NONTERM(ConstExpression));
        }
        | ConstExpression {
            $$ = alloc_NONTERMINAL(CL_CaseLabels, 85, 1, $1);
                RULE(CaseLabels, NONTERM(ConstExpression));
        }
        ;

/* 6.6. Set types */

SetType
        : SET OF SimpleType {
            $$ = alloc_NONTERMINAL(CL_SetType, 86, 3, alloc_SYMBOL(SET, $1), alloc_SYMBOL(OF, $2), $3);
                RULE(SetType, KEYWORD(SET) KEYWORD(OF) NONTERM(SimpleType));
        }
        ;

/* 6.7. Pointer types */

PointerType
        : POINTER TO type {
            $$ = alloc_NONTERMINAL(CL_PointerType, 87, 3, alloc_SYMBOL(POINTER, $1), alloc_SYMBOL(TO, $2), $3);
                RULE(PointerType, KEYWORD(POINTER) KEYWORD(TO) NONTERM(type));
        }
        ;

/* 6.8 Procedure types */

ProcedureType
        : PROCEDURE FormalTypeList {
            $$ = alloc_NONTERMINAL(CL_ProcedureType, 88, 2, alloc_SYMBOL(PROCEDURE, $1), $2);
                RULE(ProcedureType, KEYWORD(PROCEDURE) NONTERM(FormalTypeList));
        }
        | PROCEDURE {
            $$ = alloc_NONTERMINAL(CL_ProcedureType, 89, 1, alloc_SYMBOL(PROCEDURE, $1));
                RULE(ProcedureType, KEYWORD(PROCEDURE));
        }
        ;

FormalTypeList
        : paren_formal_parameter_type_list_opt ':' qualident {
            $$ = alloc_NONTERMINAL(CL_FormalTypeList, 90, 3, $1, alloc_SYMBOL(':', $2), $3);
                RULE(FormalTypeList, NONTERM(paren_formal_parameter_type_list_opt)
                    SYMBOL(":") NONTERM(qualident));
        }
        | paren_formal_parameter_type_list_opt {
            $$ = alloc_NONTERMINAL(CL_FormalTypeList, 91, 1, $1);
                RULE(FormalTypeList, NONTERM(paren_formal_parameter_type_list_opt));
        }
        ;

paren_formal_parameter_type_list_opt
        : '(' formal_parameter_type_list_opt ')' {
            $$ = alloc_NONTERMINAL(CL_paren_formal_parameter_type_list_opt, 92, 3, alloc_SYMBOL('(', $1), $2, alloc_SYMBOL(')', $3));
                RULE(paren_formal_parameter_type_list_opt, SYMBOL("(")
                    NONTERM(formal_parameter_type_list_opt) SYMBOL(")"));
        }
        ;

formal_parameter_type_list_opt
        : formal_parameter_type_list {
            $$ = alloc_NONTERMINAL(CL_formal_parameter_type_list_opt, 93, 1, $1);
                RULE(formal_parameter_type_list_opt,
                    NONTERM(formal_parameter_type_list_opt));
        }
        | /* EMPTY */ {
            $$ = alloc_NONTERMINAL(CL_formal_parameter_type_list_opt, 94, 0);
                RULE(formal_parameter_type_list_opt, EMPTY);
        }
        ;

formal_parameter_type_list
        : formal_parameter_type_list ',' formal_parameter_type {
            $$ = alloc_NONTERMINAL(CL_formal_parameter_type_list, 95, 3, $1, alloc_SYMBOL(',', $2), $3);
                RULE(formal_parameter_type_list, NONTERM(formal_parameter_type_list)
                    SYMBOL(",") NONTERM(formal_parameter_type));
        }
        | formal_parameter_type {
            $$ = alloc_NONTERMINAL(CL_formal_parameter_type_list, 96, 1, $1);
                RULE(formal_parameter_type_list, NONTERM(formal_parameter_type));
        }
        ;

formal_parameter_type
        : VAR FormalType {
            $$ = alloc_NONTERMINAL(CL_formal_parameter_type, 97, 2, alloc_SYMBOL(VAR, $1), $2);
                RULE(formal_parameter_type, KEYWORD(VAR) NONTERM(FormalType));
        }
        | FormalType {
            $$ = alloc_NONTERMINAL(CL_formal_parameter_type, 98, 1, $1);
                RULE(formal_parameter_type, NONTERM(FormalType));
        }
        ;

VariableDeclaration
        : IdentList ':' type {
            $$ = alloc_NONTERMINAL(CL_VariableDeclaration, 99, 3, $1, alloc_SYMBOL(':', $2), $3);
                RULE(VariableDeclaration, NONTERM(IdentList) SYMBOL(":") NONTERM(type));
        }
        ;

/* 8. Expressions */
/* 8.1. Operands */

designator
        : designator '.' IDENT {
            $$ = alloc_NONTERMINAL(CL_designator, 100, 3, $1, alloc_SYMBOL('.', $2), alloc_IDENT($3));
                RULE(designator, NONTERM(designator) SYMBOL(".") TERMIN("IDENT:%s"), $3);
        }
        | designator '[' ExpList ']' {
            $$ = alloc_NONTERMINAL(CL_designator, 101, 4, $1, alloc_SYMBOL('[', $2), $3, alloc_SYMBOL(']', $4));
                RULE(designator, NONTERM(designator) SYMBOL("[") NONTERM(ExpList) SYMBOL("]"));
        }
        | designator '^' {
            $$ = alloc_NONTERMINAL(CL_designator, 102, 2, $1, alloc_SYMBOL('^', $2));
                RULE(designator, NONTERM(designator) SYMBOL("^"));
        }
        | qualident {
            $$ = alloc_NONTERMINAL(CL_designator, 103, 1, $1);
                RULE(designator, NONTERM(qualident));
        }
        ;

ExpList
        : ExpList ',' expression {
            $$ = alloc_NONTERMINAL(CL_ExpList, 104, 3, $1, alloc_SYMBOL(',', $2), $3);
                RULE(ExpList, NONTERM(ExpList) SYMBOL(",") NONTERM(expression));
        }
        | expression {
            $$ = alloc_NONTERMINAL(CL_ExpList, 105, 1, $1);
                RULE(ExpList, NONTERM(expression));
        }
        ;

/* 8.2 Operators */

expression
        : SimpleExpression relation SimpleExpression {
            $$ = alloc_NONTERMINAL(CL_expression, 106, 3, $1, $2, $3);
                RULE(expression, NONTERM(SimpleExpression)
                    NONTERM(relation) NONTERM(SimpleExpression));
        }
        | SimpleExpression {
            $$ = alloc_NONTERMINAL(CL_expression, 107, 1, $1);
                RULE(expression, NONTERM(SimpleExpression));
        }
        ;

SimpleExpression
        : SimpleExpression AddOperator term {
            $$ = alloc_NONTERMINAL(CL_SimpleExpression, 108, 3, $1, $2, $3);
                RULE(SimpleExpression, NONTERM(SimpleExpression) NONTERM(AddOperator) NONTERM(term));
        }
        | add_op_opt term {
            $$ = alloc_NONTERMINAL(CL_SimpleExpression, 109, 2, $1, $2);
                RULE(SimpleExpression, NONTERM(add_op_opt) NONTERM(term));
        }
        ;

term
        : term MulOperator factor {
            $$ = alloc_NONTERMINAL(CL_term, 110, 3, $1, $2, $3);
                RULE(term, NONTERM(term) NONTERM(MulOperator) NONTERM(factor));
        }
        | factor {
            $$ = alloc_NONTERMINAL(CL_term, 111, 1, $1);
                RULE(term, NONTERM(factor));
        }
        ;

factor
        : INTEGER {
            $$ = alloc_NONTERMINAL(CL_factor, 112, 1, alloc_INTEGER($1));
                RULE( factor, TERMIN("INTEGER(%d)"), $1);
        }
        | REAL {
            $$ = alloc_NONTERMINAL(CL_factor, 113, 1, alloc_REAL($1));
                RULE(factor, TERMIN("REAL(%lg)"), $1);
        }
        | STRING {
            $$ = alloc_NONTERMINAL(CL_factor, 114, 1, alloc_STRING($1));
                RULE(factor, TERMIN("STRING(%s)"), $1);
        }
        | CHARLIT {
            $$ = alloc_NONTERMINAL(CL_factor, 115, 1, alloc_CHARLIT($1));
                RULE(factor, TERMIN("CHARLIT(\\%03o)"), $1);
        }
        | set {
            $$ = alloc_NONTERMINAL(CL_factor, 116, 1, $1);
                RULE(factor, NONTERM(set));
        }
        | designator ActualParameters {
            $$ = alloc_NONTERMINAL(CL_factor, 117, 2, $1, $2);
                RULE(factor, NONTERM(designator) NONTERM(ActualParameters));
        }
        | designator {
            $$ = alloc_NONTERMINAL(CL_factor, 118, 1, $1);
                RULE(factor, NONTERM(designator));
        }
        | '(' expression ')' {
            $$ = alloc_NONTERMINAL(CL_factor, 119, 3, alloc_SYMBOL('(', $1), $2, alloc_SYMBOL(')', $3));
                RULE(factor, SYMBOL("(") NONTERM(expression) SYMBOL(")"));
        }
        | NOT factor {
            $$ = alloc_NONTERMINAL(CL_factor, 120, 2, alloc_SYMBOL(NOT, $1), $2);
                RULE(factor, KEYWORD(NOT) NONTERM(factor));
        }
        ;

ActualParameters
        : '(' ExpList ')' {
            $$ = alloc_NONTERMINAL(CL_ActualParameters, 121, 3, alloc_SYMBOL('(', $1), $2, alloc_SYMBOL(')', $3));
                RULE(ActualParameters, SYMBOL("(") NONTERM(ExpList) SYMBOL(")"));
        }
        | '(' ')' {
            $$ = alloc_NONTERMINAL(CL_ActualParameters, 122, 2, alloc_SYMBOL('(', $1), alloc_SYMBOL(')', $2));
                RULE(ActualParameters, SYMBOL("(") SYMBOL(")"));
        }
        ;

/* 9. Statements */

statement
        : assignment {
            $$ = alloc_NONTERMINAL(CL_statement, 123, 1, $1);
                RULE(statement, NONTERM(assignment));
        }
        | ProcedureCall {
            $$ = alloc_NONTERMINAL(CL_statement, 124, 1, $1);
                RULE(statement, NONTERM(ProcedureCall));
        }
        | IfStatement {
            $$ = alloc_NONTERMINAL(CL_statement, 125, 1, $1);
                RULE(statement, NONTERM(IfStatement));
        }
        | CaseStatement {
            $$ = alloc_NONTERMINAL(CL_statement, 126, 1, $1);
                RULE(statement, NONTERM(CaseStatement));
        }
        | WhileStatement {
            $$ = alloc_NONTERMINAL(CL_statement, 127, 1, $1);
                RULE(statement, NONTERM(WhileStatement));
        }
        | RepeatStatement {
            $$ = alloc_NONTERMINAL(CL_statement, 128, 1, $1);
                RULE(statement, NONTERM(RepeatStatement));
        }
        | LoopStatement {
            $$ = alloc_NONTERMINAL(CL_statement, 129, 1, $1);
                RULE(statement, NONTERM(LoopStatement));
        }
        | ForStatement {
            $$ = alloc_NONTERMINAL(CL_statement, 130, 1, $1);
                RULE(statement, NONTERM(ForStatement));
        }
        | WithStatement {
            $$ = alloc_NONTERMINAL(CL_statement, 131, 1, $1);
                RULE(statement, NONTERM(WithStatement));
        }
        | EXIT {
            $$ = alloc_NONTERMINAL(CL_statement, 132, 1, alloc_SYMBOL(EXIT, $1));
                RULE(statement, KEYWORD(EXIT));
        }
        | TRETURN expression {
            $$ = alloc_NONTERMINAL(CL_statement, 133, 2, alloc_SYMBOL(TRETURN, $1), $2);
                RULE(statement, KEYWORD(RETURN)NONTERM(expression));
        }
        | TRETURN {
            $$ = alloc_NONTERMINAL(CL_statement, 134, 1, alloc_SYMBOL(TRETURN, $1));
                RULE(statement, KEYWORD(RETURN));
        }
        | /* empty */ {
            $$ = alloc_NONTERMINAL(CL_statement, 135, 0);
                RULE(statement, EMPTY);
        }
        ;

/* 9.1. Assignments */

assignment
        : designator ASSIGN expression {
            $$ = alloc_NONTERMINAL(CL_assignment, 136, 3, $1, alloc_SYMBOL(ASSIGN, $2), $3);
                RULE(assignment, NONTERM(designator) SYMBOL(":=") NONTERM(expression));
        }
        ;

/* 9.2. Procedure calls */

ProcedureCall
        : designator ActualParameters {
            $$ = alloc_NONTERMINAL(CL_ProcedureCall, 137, 2, $1, $2);
                RULE(ProcedureCall, NONTERM(designator) NONTERM(ActualParameters));
        }
        | designator {
            $$ = alloc_NONTERMINAL(CL_ProcedureCall, 138, 1, $1);
                RULE(ProcedureCall, NONTERM(designator));
        }
        ;

/* 9.3. Statement sequences */

StatementSequence
        : StatementSequence ';' statement {
            $$ = alloc_NONTERMINAL(CL_StatementSequence, 139, 3, $1, alloc_SYMBOL(';', $2), $3);
                RULE(StatementSequence, NONTERM(StatementSequence) SYMBOL(";") NONTERM(statement));
        }
        | statement {
            $$ = alloc_NONTERMINAL(CL_StatementSequence, 140, 1, $1);
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
            $$ = alloc_NONTERMINAL(CL_IfStatement, 141, 7, alloc_SYMBOL(IF, $1), $2, alloc_SYMBOL(THEN, $3), $4, $5, $6, alloc_SYMBOL(END, $7));
                RULE(IfStatement, KEYWORD(IF) NONTERM(expression) KEYWORD(THEN)
                    NONTERM(StatementSequence) NONTERM(elsif_seq) NONTERM(else_opt)
                    KEYWORD(END));
        }
        ;

elsif_seq
        : elsif_seq ELSIF expression THEN StatementSequence {
            $$ = alloc_NONTERMINAL(CL_elsif_seq, 142, 5, $1, alloc_SYMBOL(ELSIF, $2), $3, alloc_SYMBOL(THEN, $4), $5);
                RULE(elsif_seq, NONTERM(elsif_seq) KEYWORD(ELSIF)
                    NONTERM(expression) KEYWORD(THEN) NONTERM(StatementSequence));
        }
        | /* EMPTY */ {
            $$ = alloc_NONTERMINAL(CL_elsif_seq, 143, 0);
                RULE(elsif_seq, EMPTY);
        }
        ;

else_opt
        : ELSE StatementSequence {
            $$ = alloc_NONTERMINAL(CL_else_opt, 144, 2, alloc_SYMBOL(ELSE, $1), $2);
                RULE(else_opt, KEYWORD(ELSE) NONTERM(StatementSequence));
        }
        | /* EMPTY */ {
            $$ = alloc_NONTERMINAL(CL_else_opt, 145, 0);
                RULE(else_opt, EMPTY);
        }
        ;

/* 9.5. Case statements */

CaseStatement
        : CASE expression OF
            case_list
            else_opt
          END {
            $$ = alloc_NONTERMINAL(CL_CaseStatement, 146, 6, alloc_SYMBOL(CASE, $1), $2, alloc_SYMBOL(OF, $3), $4, $5, alloc_SYMBOL(END, $6));
                RULE(CaseStatement, KEYWORD(CASE) NONTERM(expression) KEYWORD(OF)
                    NONTERM(case_list) NONTERM(else_opt) KEYWORD(END));
        }
        ;

case_list
        : case_list '|' case {
            $$ = alloc_NONTERMINAL(CL_case_list, 147, 3, $1, alloc_SYMBOL('|', $2), $3);
                RULE(case_list, NONTERM(case_list) SYMBOL("|") NONTERM(case));
        }
        | case {
            $$ = alloc_NONTERMINAL(CL_case_list, 148, 1, $1);
                RULE(case_list, NONTERM(case));
        }
        ;

case
        : CaseLabelList ':' StatementSequence {
            $$ = alloc_NONTERMINAL(CL_case, 149, 3, $1, alloc_SYMBOL(':', $2), $3);
                RULE(case, NONTERM(CaseLabelList) SYMBOL(":") NONTERM(StatementSequence));
        }
        ;

/* 9.6. While statements */

WhileStatement
        : WHILE expression DO
            StatementSequence
          END {
            $$ = alloc_NONTERMINAL(CL_WhileStatement, 150, 5, alloc_SYMBOL(WHILE, $1), $2, alloc_SYMBOL(DO, $3), $4, alloc_SYMBOL(END, $5));
                RULE(WhileStatement, KEYWORD(WHILE) NONTERM(expression) KEYWORD(DO)
                    NONTERM(StatementSequence) KEYWORD(END));
        }
        ;

/* 9.7. Repeat statements */

RepeatStatement
        : REPEAT
            StatementSequence
          UNTIL expression {
            $$ = alloc_NONTERMINAL(CL_RepeatStatement, 151, 4, alloc_SYMBOL(REPEAT, $1), $2, alloc_SYMBOL(UNTIL, $3), $4);
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
            $$ = alloc_NONTERMINAL(CL_ForStatement, 152, 10, alloc_SYMBOL(FOR, $1), alloc_IDENT($2), alloc_SYMBOL(ASSIGN, $3),
            $4, alloc_SYMBOL(TO, $5), $6, $7, alloc_SYMBOL(DO, $8), $9, alloc_SYMBOL(END, $10));
                RULE(ForStatement, KEYWORD(FOR) TERMIN("IDENT:%s") SYMBOL(":=")
                    NONTERM(expression) KEYWORD(TO) NONTERM(expression)
                    NONTERM(by_opt) KEYWORD(DO) NONTERM(StatementSequence)
                    KEYWORD(END), $2);
        }
        ;

by_opt
        : BY ConstExpression {
            $$ = alloc_NONTERMINAL(CL_by_opt, 153, 2, alloc_SYMBOL(BY, $1), $2);
                RULE(by_opt, KEYWORD(BY) NONTERM(ConstExpression));
        }
        | /* empty */ {
            $$ = alloc_NONTERMINAL(CL_by_opt, 154, 0);
                RULE(by_opt, EMPTY);
        }
        ;

/* 9.9. Loop statements */

LoopStatement
        : LOOP
            StatementSequence
          END {
            $$ = alloc_NONTERMINAL(CL_LoopStatement, 155, 3, alloc_SYMBOL(LOOP, $1), $2, alloc_SYMBOL(END, $3));
                RULE(LoopStatement, KEYWORD(LOOP) NONTERM(StatementSequence)
                    KEYWORD(END));
        }
        ;

/* 9.10. With statements */

WithStatement
        : WITH designator DO StatementSequence END {
            $$ = alloc_NONTERMINAL(CL_WithStatement, 156, 5, alloc_SYMBOL(WITH, $1), $2, alloc_SYMBOL(DO, $3), $4, alloc_SYMBOL(END, $3));
                RULE(WithStatement, KEYWORD(WITH) NONTERM(designator)
                    KEYWORD(DO) NONTERM(StatementSequence) KEYWORD(END));
        }
        ;

/* 10. Procedure declarations */

ProcedureDeclaration
        : ProcedureHeading ';' block IDENT {
            $$ = alloc_NONTERMINAL(CL_ProcedureDeclaration, 157, 4, $1, alloc_SYMBOL(';', $2), $3, alloc_IDENT($4));
            RULE(ProcedureDeclaration, NONTERM(ProcedureHeading)
            SYMBOL(";") NONTERM(block) TERMIN("IDENT:%s"), $4);
        }
        ;

ProcedureHeading
        : PROCEDURE IDENT FormalParameters_opt {
            $$ = alloc_NONTERMINAL(CL_ProcedureHeading, 158, 3, alloc_SYMBOL(PROCEDURE, $1), alloc_IDENT($2), $3);
                RULE(ProcedureHeading, KEYWORD(PROCEDURE) TERMIN("IDENT:%s")
                    NONTERM(FormalParameters_opt), $2);
        }
        ;

FormalParameters_opt
        : FormalParameters {
            $$ = alloc_NONTERMINAL(CL_FormalParameters_opt, 159, 1, $1);
                RULE(FormalParameters_opt, NONTERM(FormalParameters));
        }
        | /* empty */ {
            $$ = alloc_NONTERMINAL(CL_FormalParameters_opt, 160, 0);
                RULE(FormalParameters_opt, EMPTY);
        }
        ;

block
        : declaration_list_opt
          BEGIN_StatementSequence_opt
          END {
            $$ = alloc_NONTERMINAL(CL_block, 161, 3, $1, $2, alloc_SYMBOL(END, $3));
                RULE(block, NONTERM(declaration_list_opt)
                    NONTERM(BEGIN_StatementSequence_opt) KEYWORD(END));
        }
        ;

declaration_list_opt
        : declaration_list_opt declaration {
            $$ = alloc_NONTERMINAL(CL_declaration_list_opt, 162, 2, $1, $2);
                RULE(declaration_list_opt, NONTERM(declaration_list_opt)
                    NONTERM(declaration));
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
                RULE(declaration_list_opt, EMPTY);
        }
        ;

BEGIN_StatementSequence_opt
        : TBEGIN StatementSequence {
            $$ = alloc_NONTERMINAL(CL_BEGIN_StatementSequence_opt, 164, 2, alloc_SYMBOL(TBEGIN, $1), $2);
                RULE(BEGIN_StatementSequence_opt, KEYWORD(BEGIN)
                    NONTERM(StatementSequence));
        }
        | /* empty */ {
            $$ = alloc_NONTERMINAL(CL_BEGIN_StatementSequence_opt, 165, 0);
                RULE(BEGIN_StatementSequence_opt, EMPTY);
        }
        ;

declaration
        : CONST ConstantDeclaration_list_opt {
            $$ = alloc_NONTERMINAL(CL_declaration, 166, 2, alloc_SYMBOL(CONST, $1), $2);
                RULE(declaration, KEYWORD(CONST) NONTERM(ConstantDeclaration_list_opt));
        }
        | TYPE TypeDeclaration_list_opt {
            $$ = alloc_NONTERMINAL(CL_declaration, 167, 2, alloc_SYMBOL(TYPE, $1), $2);
                RULE(declaration, KEYWORD(TYPE) NONTERM(TypeDeclaration_list_opt));
        }
        | VAR VariableDeclaration_list_opt {
            $$ = alloc_NONTERMINAL(CL_declaration, 168, 2, alloc_SYMBOL(VAR, $1), $2);
                RULE(declaration, KEYWORD(VAR) NONTERM(VariableDeclaration_list_opt));
        }
        | ProcedureDeclaration ';' {
            $$ = alloc_NONTERMINAL(CL_declaration, 169, 2, $1, alloc_SYMBOL(';', $2));
                RULE(declaration, NONTERM(ProcedureDeclaration) SYMBOL(";"));
        }
        | ModuleDeclaration ';' {
            $$ = alloc_NONTERMINAL(CL_declaration, 170, 2, $1, alloc_SYMBOL(';', $2));
                RULE(declaration, NONTERM(ModuleDeclaration) SYMBOL(";"));
        }
        ;

ConstantDeclaration_list_opt
        : ConstantDeclaration_list_opt ConstantDeclaration ';' {
            $$ = alloc_NONTERMINAL(CL_ConstantDeclaration_list_opt, 171, 3, $1, $2, alloc_SYMBOL(';', $3));
                RULE(ConstantDeclaration_list_opt, NONTERM(ConstantDeclaration_list_opt)
                    NONTERM(ConstantDeclaration) SYMBOL(";"));
        }
        | /* empty */ {
            $$ = alloc_NONTERMINAL(CL_ConstantDeclaration_list_opt, 172, 0);
                RULE(ConstantDeclaration_list_opt, EMPTY);
        }
        ;

TypeDeclaration_list_opt
        : TypeDeclaration_list_opt TypeDeclaration ';' {
            $$ = alloc_NONTERMINAL(CL_TypeDeclaration_list_opt, 173, 3, $1, $2, alloc_SYMBOL(';', $3));
                RULE(TypeDeclaration_list_opt, NONTERM(TypeDeclaration_list_opt)
                    NONTERM(TypeDeclaration) SYMBOL(";"));
        }
        | /* empty */ {
            $$ = alloc_NONTERMINAL(CL_TypeDeclaration_list_opt, 174, 0);
                RULE(TypeDeclaration_list_opt, EMPTY);
        }
        ;

VariableDeclaration_list_opt
        : VariableDeclaration_list_opt VariableDeclaration ';' {
            $$ = alloc_NONTERMINAL(CL_VariableDeclaration_list_opt, 175, 3, $1, $2, alloc_SYMBOL(';', $3));
                RULE(VariableDeclaration_list_opt, NONTERM(VariableDeclaration_list_opt)
                    NONTERM(VariableDeclaration) SYMBOL(";"));
        }
        | /* empty */ {
            $$ = alloc_NONTERMINAL(CL_VariableDeclaration_list_opt, 176, 0);
                RULE(VariableDeclaration_list_opt, EMPTY);
        }
        ;

/* 10.1. Formal parameters */

FormalParameters
        : '(' FPSection_list_opt ')' ':' qualident {
            $$ = alloc_NONTERMINAL(CL_FormalParameters, 177, 5, alloc_SYMBOL('(', $1), $2, alloc_SYMBOL(')', $3), alloc_SYMBOL(':', $4), $5);
                RULE(FormalParameters, SYMBOL("(") NONTERM(FPSection_list_opt)
                    SYMBOL(")") SYMBOL(":") NONTERM(qualident));
        }
        | '(' FPSection_list_opt ')' {
            $$ = alloc_NONTERMINAL(CL_FormalParameters, 178, 3, alloc_SYMBOL('(', $1), $2, alloc_SYMBOL(')', $3));
                RULE(FormalParameters, SYMBOL("(") NONTERM(FPSection_list_opt)
                    SYMBOL(")"));
        }
        ;

FPSection_list_opt
        : FPSection_list {
            $$ = alloc_NONTERMINAL(CL_FPSection_list_opt, 179, 1, $1);
                RULE(FPSection_list_opt, NONTERM(FPSection_list));
        }
        | /* empty */ {
            $$ = alloc_NONTERMINAL(CL_FPSection_list_opt, 180, 0);
                RULE(FPSection_list_opt, EMPTY);
        }
        ;

FPSection_list
        : FPSection_list ';' FPSection {
            $$ = alloc_NONTERMINAL(CL_FPSection_list, 181, 3, $1, alloc_SYMBOL(';', $2), $3);
                RULE(FPSection_list, NONTERM(FPSection_list) SYMBOL(";") NONTERM(FPSection));
        }
        | FPSection {
            $$ = alloc_NONTERMINAL(CL_FPSection_list, 182, 1, $1);
                RULE(FPSection_list, NONTERM(FPSection));
        }
        ;

FPSection
        : VAR IdentList ':' FormalType {
            $$ = alloc_NONTERMINAL(CL_FPSection, 183, 4, alloc_SYMBOL(VAR, $1), $2, alloc_SYMBOL(':', $3), $4);
                RULE(FPSection, KEYWORD(VAR) NONTERM(IdentList) SYMBOL(":") NONTERM(FormalType));
        }
        |     IdentList ':' FormalType {
            $$ = alloc_NONTERMINAL(CL_FPSection, 184, 3, $1, alloc_SYMBOL(':', $2), $3);
                RULE(FPSection, NONTERM(IdentList) SYMBOL(":") NONTERM(FormalType));
        }
        ;

FormalType
        : ARRAY OF qualident {
            $$ = alloc_NONTERMINAL(CL_FormalType, 185, 3, alloc_SYMBOL(ARRAY, $1), alloc_SYMBOL(OF, $2), $3);
                RULE(FormalType, KEYWORD(ARRAY) KEYWORD(OF) NONTERM(qualident));
        }
        | qualident {
            $$ = alloc_NONTERMINAL(CL_FormalType, 186, 1, $1);
                RULE(FormalType, NONTERM(qualident));
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
                RULE(ModuleDeclaration, KEYWORD(MODULE) TERMIN("IDENT:%s") NONTERM(priority_opt) SYMBOL(";")
                    NONTERM(import_list_opt) NONTERM(export_opt) NONTERM(block) TERMIN("IDENT:%s"), $2, $8);
        }
        ;

priority_opt
        : '[' ConstExpression ']' {
            $$ = alloc_NONTERMINAL(CL_priority_opt, 188, 3, alloc_SYMBOL('[', $1), $2, alloc_SYMBOL(']', $3));
                RULE(priority_opt, SYMBOL("[") NONTERM(ConstExpression) SYMBOL("]"));
        }
        | /* empty */ {
            $$ = alloc_NONTERMINAL(CL_priority_opt, 189, 0);
                RULE(priority_opt, EMPTY);
        }
        ;

import_list_opt
        : import_list_opt import {
            $$ = alloc_NONTERMINAL(CL_import_list_opt, 190, 2, $1, $2);
                RULE(import_list_opt, NONTERM(import_list_opt) NONTERM(import));
        }
        | /* empty */ {
            $$ = alloc_NONTERMINAL(CL_import_list_opt, 191, 0);
                RULE(import_list_opt, EMPTY);
        }
        ;

export_opt
        : EXPORT QUALIFIED IdentList ';' {
            $$ = alloc_NONTERMINAL(CL_export_opt, 192, 4, alloc_SYMBOL(EXPORT, $1), alloc_SYMBOL(QUALIFIED, $2), $3, alloc_SYMBOL(';', $4));
                RULE(export_opt, KEYWORD(EXPORT) KEYWORD(QUALIFIED) NONTERM(IdentList) SYMBOL(";"));
        }
        | EXPORT IdentList ';' {
            $$ = alloc_NONTERMINAL(CL_export_opt, 193, 3, alloc_SYMBOL(EXPORT, $1), $2, alloc_SYMBOL(';', $3));
                RULE(export_opt, KEYWORD(EXPORT) NONTERM(IdentList) SYMBOL(";"));
        }
        | /* empty */ {
            $$ = alloc_NONTERMINAL(CL_export_opt, 194, 0);
                RULE(export_opt, EMPTY);
        }
        ;

import
        : FROM IDENT IMPORT IdentList ';' {
            $$ = alloc_NONTERMINAL(CL_import, 195, 5, alloc_SYMBOL(FROM, $1), alloc_IDENT($2),
                    alloc_SYMBOL(IMPORT, $3), $4, alloc_SYMBOL(';', $5));
                RULE(import, KEYWORD(FROM) TERMIN("IDENT:%s") KEYWORD(IMPORT)
                    NONTERM(IdentList) SYMBOL(";"), $2);
        }
        |        IMPORT IdentList ';' {
            $$ = alloc_NONTERMINAL(CL_import, 196, 3, alloc_SYMBOL(IMPORT, $1), $2, alloc_SYMBOL(';', $3));
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
            $$ = alloc_NONTERMINAL(CL_DefinitionModule, 197, 9, alloc_SYMBOL(DEFINITION, $1), alloc_SYMBOL(MODULE, $2),
                alloc_IDENT($3), alloc_SYMBOL(';', $4), $5, $6, $7, alloc_SYMBOL(END, $8), alloc_IDENT($9));
                RULE(DefinitionModule, KEYWORD(DEFINITION) KEYWORD(MODULE) TERMIN("IDENT:%s") SYMBOL(";")
                    NONTERM(import_list_opt) NONTERM(export_opt) NONTERM(definition_list_opt)
                    KEYWORD(END) TERMIN("IDENT:%s"), $3, $9);
        }
        ;

definition_list_opt
        : definition_list_opt definition {
            $$ = alloc_NONTERMINAL(CL_definition_list_opt, 198, 2, $1, $2);
                RULE(definition_list_opt, NONTERM(definition_list_opt) NONTERM(definition));
        }
        | /* empty */ {
            $$ = alloc_NONTERMINAL(CL_definition_list_opt, 199, 0);
                RULE(definition_list_opt, EMPTY);
        }
        ;

definition
        : CONST ConstantDeclaration_list_opt {
            $$ = alloc_NONTERMINAL(CL_definition, 200, 2, alloc_SYMBOL(CONST, $1), $2);
                RULE(definition, KEYWORD(CONST) NONTERM(ConstantDeclaration_list_opt));
        }
        | TYPE opaque_type_list_opt {
            $$ = alloc_NONTERMINAL(CL_definition, 201, 2, alloc_SYMBOL(TYPE, $1), $2);
                RULE(definition, KEYWORD(TYPE) NONTERM(opaque_type_list_opt));
        }
        | VAR VariableDeclaration_list_opt {
            $$ = alloc_NONTERMINAL(CL_definition, 202, 2, alloc_SYMBOL(VAR, $1), $2);
                RULE(definition, KEYWORD(VAR) NONTERM(VariableDeclaration_list_opt));
        }
        | ProcedureHeading ';' {
            $$ = alloc_NONTERMINAL(CL_definition, 203, 2, $1, alloc_SYMBOL(';', $2));
                RULE(definition, NONTERM(ProcedureHeading) SYMBOL(";"));
        }
        ;

opaque_type_list_opt
        : opaque_type_list_opt opaque_type {
            $$ = alloc_NONTERMINAL(CL_opaque_type_list_opt, 204, 2, $1, $2);
                RULE(opaque_type_list_opt, NONTERM(opaque_type_list_opt) NONTERM(opaque_type));
        }
        | /* empty */ {
            $$ = alloc_NONTERMINAL(CL_opaque_type_list_opt, 205, 0);
                RULE(opaque_type_list_opt, EMPTY);
        }
        ;

opaque_type
        : IDENT '=' type ';' {
            $$ = alloc_NONTERMINAL(CL_opaque_type, 206, 4, alloc_IDENT($1), alloc_SYMBOL('=', $2), $3, alloc_SYMBOL(';', $4));
                RULE(opaque_type, TERMIN("IDENT:%s") SYMBOL("=") NONTERM(type) SYMBOL(";"), $1);
        }
        | IDENT ';' {
            $$ = alloc_NONTERMINAL(CL_opaque_type, 207, 2, alloc_IDENT($1), alloc_SYMBOL(';', $2));
                RULE(opaque_type, TERMIN("IDENT:%s") SYMBOL(";"), $1);
        }
        ;

ProgramModule
        : MODULE IDENT priority_opt ';'
            import_list_opt
          block IDENT {
            $$ = alloc_NONTERMINAL(CL_ProgramModule, 208, 7, alloc_SYMBOL(MODULE, $1), alloc_IDENT($2), $3,
            alloc_SYMBOL(';', $4), $5, $6, alloc_IDENT($7));
                RULE(ProgramModule, KEYWORD(MODULE) TERMIN("IDENT:%s") NONTERM(priority_opt) SYMBOL(";")
                    NONTERM(import_list_opt) NONTERM(block) TERMIN("IDENT:%s"), $2, $7);
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
