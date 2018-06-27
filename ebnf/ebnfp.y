%{
/* ebnfp.y -- parser grammar for the ebnf language.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Wed May  9 11:57:06 EEST 2018
 */

#include <stdio.h>

#include "ebnfs.h"
#include "ebnfp.h"
#include "bgram.h"
#include "brule.h"
#include "balts.h"
#include "balt.h"
#include "bterm.h"

#define YYDEBUG (1)

int yylex(void);
int yyerror(const char *msg);

#define TERMINAL(x) " \033[33m" #x
#define NONTERM(x) " \033[37m" #x ""
#define SYMB(x) " \033[31m" x 
#define EMPTY() " \033[32m/* EMPTY */"
#define STRNG(x) " \033[32m'" x "'"
#define RULE(LS, RS) do{					\
		if (main_flags & FLAG_TRACE_PARSE)	\
			printf(F(NONTERM(LS) SYMB(":")	\
				RS SYMB(";")"\033[m\n"));	\
	}while(0)

bnf_grammar_t bnf_main_grammar;

%}

%token <tok> STRING
%token <tok> IDENT
%type <grammar> grammar
%type <rule> rule
%type <alternative_list> alternative_list right_side
%type <alternative> alternative
%type <term> term

%union {
	const_bnf_token_t			tok;
	bnf_grammar_t				grammar; /* key is left identifier (the nonterminal IDENT) */
	bnf_rule_t					rule;
	bnf_alternative_set_t		alternative_list; /* key is the pair of head alternative_list and the tail alternative */
	bnf_alternative_t			alternative;
	bnf_term_t					term;
}

%%

source: grammar {
      bnf_main_grammar = $1;
    } ;

grammar: grammar rule {
			$$ = bnf_grammar($1, $2);
			RULE(grammar, NONTERM(grammar) NONTERM(rule));
	   }
       | rule {
            $$ = bnf_grammar(NULL, $1);
			RULE(grammar, NONTERM(rule));
       } ;

rule: IDENT ':' right_side ';' {
            $$ = bnf_rule($1, $3);
			RULE(rule, TERMINAL(IDENT) STRNG(":") NONTERM(right_side) STRNG(";"));
    }
	| IDENT ':' ';' {
            $$ = bnf_rule($1, NULL);
			RULE(rule, TERMINAL(IDENT) STRNG(":") STRNG(";"));
	} ;

right_side:
      alternative_list {
            $$ = $1; /* just copy up */
            RULE(right_side, NONTERM(alternative_list));
    }
    | alternative_list '|' {
            $$ = bnf_alternative_set($1, bnf_alternative(NULL, NULL)); /* add the empty alternative */
            RULE(right_side, NONTERM(alternative_list) STRNG("|"));
    }
    | '|' alternative_list {
            $$ = bnf_alternative_set($2, bnf_alternative(NULL, NULL)); /* add the empty alternative (alternatives are commutative) */
            RULE(right_side, STRNG("|") NONTERM(alternative_list));
    }
    | alternative_list '|' '|' alternative_list {
            $$ = bnf_merge_alternative_sets(bnf_alternative_set($1, bnf_alternative(NULL, NULL)), $4);
            RULE(right_side, NONTERM(alternative_list) STRNG("|") STRNG("|") NONTERM(alternative_list));
    } ;

alternative_list:
      alternative_list '|' alternative {
            $$ = bnf_alternative_set($1, $3);
            RULE(alternative_list, NONTERM(alternative_list) STRNG("|") NONTERM(alternative));
    }
    | alternative {
            $$ = bnf_alternative_set(NULL, $1);
            RULE(alternative_list, NONTERM(alternative));
    }
    ;

alternative:
      alternative term {
            $$ = bnf_alternative($1, $2);
			RULE(alternative, NONTERM(alternative) NONTERM(term));
    }
	| term {
            $$ = bnf_alternative(NULL, $1);
			RULE(alternative, NONTERM(term));
    }
	;

term:
	IDENT {
            $$ = bnf_term_ident($1);
			RULE(term, TERMINAL(IDENT));
    }
	| STRING {
            $$ = bnf_term_strng($1);
			RULE(term, TERMINAL(STRING));
    }
	| '{' alternative_list '}' {
            $$ = bnf_term_reptd($2);
			RULE(term, STRNG("{") NONTERM(alternative_list) STRNG("}"));
    }
	| '[' alternative_list ']' {
            $$ = bnf_term_optnl($2);
			RULE(term, STRNG("[") NONTERM(alternative_list) STRNG("]"));
    }
	| '(' alternative_list ')' {
            $$ = bnf_term_paren($2);
			RULE(term, STRNG("(") NONTERM(alternative_list) STRNG(")"));
    }
	;

%%

int yyerror(const char *msg)
{
	extern int yylineno;
	fprintf(stderr, F("line %d: %s\n"), yylineno, msg);
	return 0;
}
