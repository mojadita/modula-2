%{
/* ebnfp.y -- parser grammar for the ebnf language.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Wed May  9 11:57:06 EEST 2018
 */

#include <stdio.h>

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

%token <string> STRING
%token <id> IDENT
%type <grammar> grammar
%type <rule> rule
%type <right_side> right_side
%type <alternative> alternative
%type <term> term

%union {
	bnf_token_t			string;
	bnf_token_t			id;
	bnf_grammar_t		grammar;
	bnf_rule_t			rule;
	bnf_right_side_t	right_side;
	bnf_alternative_t	alternative;
	bnf_term_t			term;
}

%%

grammar: grammar rule {
			RULE(grammar, NONTERM(grammar) NONTERM(rule));
			$$ = bnf_grammar($1, $2);
	   }
       | /* empty */ {
			RULE(grammar, EMPTY());
            $$ = NULL;
       }
       ;

rule: IDENT ':' right_side ';' {
			RULE(rule, TERMINAL(IDENT) STRNG(":") NONTERM(right_side) STRNG(";"));
            $$ = bnf_rule($1, $3);
    }
	| IDENT ':' ';' {
			RULE(rule, TERMINAL(IDENT) STRNG(":") STRNG(";"));
            $$ = bnf_rule($1, NULL);
	}
    ;

right_side:
      right_side '|' alternative {
			RULE(right_side, NONTERM(right_side) STRNG("|") NONTERM(alternative));
            $$ = bnf_right_side($1, $3);
    }
    | right_side '|' {
			RULE(right_side, NONTERM(right_side) STRNG("|"));
            $$ = bnf_right_side($1, NULL);
    }
	| alternative {
			RULE(right_side, NONTERM(alternative));
            $$ = bnf_right_side(NULL, $1);
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
            $$ = bnf_term_reptd_rs($2);
    }
	| '[' right_side ']' {
			RULE(term, STRNG("[") NONTERM(right_side) STRNG("]"));
            $$ = bnf_term_optnl_rs($2);
    }
	| '(' right_side ')' {
			RULE(term, STRNG("(") NONTERM(right_side) STRNG(")"));
            $$ = bnf_term_paren_rs($2);
    }
	;

%%

int yyerror(const char *msg)
{
	extern int yylineno;
	fprintf(stderr, F("line %d: %s\n"), yylineno, msg);
	return 0;
}
