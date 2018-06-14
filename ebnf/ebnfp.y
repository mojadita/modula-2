%{
/* ebnfp.y -- parser grammar for the ebnf language.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Wed May  9 11:57:06 EEST 2018
 */

#include <stdio.h>

#include "ebnfs.h"
#include "ebnfp.h"

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
	AVL_TREE					grammar; /* key is left identifier (the nonterminal IDENT) */
	bnf_rule_t					rule;
	AVL_TREE					alternative_list; /* key is the pair of head alternative_list and the tail alternative */
	bnf_alternative_t			alternative;
	bnf_term_t					term;
}

%%

grammar: grammar rule {
			RULE(grammar, NONTERM(grammar) NONTERM(rule));
			$$ = bnf_grammar($1, $2);
	   }
       | rule {
			RULE(grammar, NONTERM(rule));
            $$ = bnf_grammar(NULL, $1);
       } ;

rule: IDENT ':' right_side ';' {
			RULE(rule, TERMINAL(IDENT) STRNG(":") NONTERM(right_side) STRNG(";"));
            $$ = bnf_rule($1, $3);
    }
	| IDENT ':' ';' {
			RULE(rule, TERMINAL(IDENT) STRNG(":") STRNG(";"));
            $$ = bnf_rule($1, NULL);
	} ;

right_side:
      alternative_list {
            RULE(right_side, NONTERM(alternative_list));
            $$ = $1; /* just copy up */
    }
    | alternative_list '|' {
            RULE(right_side, NONTERM(alternative_list) STRNG("|"));
            $$ = bnf_alternative_list($1, NULL); /* add the empty alternative */
    }
    | '|' alternative_list {
            RULE(right_side, STRNG("|") NONTERM(alternative_list));
            $$ = bnf_alternative_list($2, NULL); /* add the empty alternative (alternatives are commutative) */
    }
    | alternative_list '|' '|' alternative_list {
            RULE(right_side, NONTERM(alternative_list) STRNG("|") STRNG("|") NONTERM(alternative_list));
            $$ = bnf_concat_alternative_lists(bnf_alternative_list($1, NULL), $4);
    } ;

alternative_list:
      alternative_list '|' alternative {
            RULE(alternative_list, NONTERM(alternative_list) STRNG("|") NONTERM(alternative));
            $$ = bnf_alternative_list($1, $3);
    }
    | alternative {
            RULE(alternative_list, NONTERM(alternative));
            $$ = bnf_alternative_list(NULL, $1);
    }
    ;

alternative:
      alternative term {
			RULE(alternative, NONTERM(alternative) NONTERM(term));
            $$ = bnf_alternative($1, $2);
    }
	| term {
			RULE(alternative, NONTERM(term));
            $$ = bnf_alternative(NULL, $1);
    }
	;

term:
	IDENT {
			RULE(term, TERMINAL(IDENT));
            $$ = bnf_term_ident($1);
    }
	| STRING {
			RULE(term, TERMINAL(STRING));
            $$ = bnf_term_string($1);
    }
	| '{' right_side '}' {
			RULE(term, STRNG("{") NONTERM(right_side) STRNG("}"));
            $$ = bnf_term_reptd($2);
    }
	| '[' right_side ']' {
			RULE(term, STRNG("[") NONTERM(right_side) STRNG("]"));
            $$ = bnf_term_optnl($2);
    }
	| '(' right_side ')' {
			RULE(term, STRNG("(") NONTERM(right_side) STRNG(")"));
            $$ = bnf_term_paren($2);
    }
	;

%%

int yyerror(const char *msg)
{
	extern int yylineno;
	fprintf(stderr, F("line %d: %s\n"), yylineno, msg);
	return 0;
}
