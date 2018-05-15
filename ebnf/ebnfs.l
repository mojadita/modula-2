%{
/* ebnfs.l -- lexical scanner for the ebnf interpreter.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Wed May  9 10:48:26 EEST 2018
 */

#include <stdio.h>
#include <string.h>

#include "ebnfp.h"
#include "y.tab.h"

#ifndef DEBUG
#define DEBUG (1)
#endif
#define SYMBOL		(yytext[0])

#if DEBUG
#define PRE_TOKEN	"\033[1;37;44m"
#define PRE_LPAREN	RESET "\033[1;37m"
#define PRE_LEXEM	"\033[32m"
#define PRE_RPAREN	"\033[37m"
#define RESET "\033[m"
#define RETURN(tok) do{													\
						printf(F("TOKEN: " PRE_TOKEN #tok PRE_LPAREN	\
						"(" PRE_LEXEM "%s" PRE_RPAREN ")" RESET "\n"),	\
						yytext);										\
						return(tok);									\
					}while(0)
#else
#define RETURN(tok) do{return(tok);}while(0)
#endif /* DEBUG */

%}

ident		[a-zA-Z_$][a-zA-Z0-9_]*
s1			"'"([^'\n]|'')*"'"
s2			"\""([^\"\n]|\"\")*"\""
string		({s1}|{s2})

%x			COMM

%%

"/*"		BEGIN(COMM);
<COMM>"*/"	BEGIN(INITIAL);
<COMM>.		|
<COMM>\n	;
{string}	RETURN(STRING);
{ident}		RETURN(IDENT);
" "			|
\t			|
\r?\n		;
.			RETURN(SYMBOL);

%%

int yywrap()
{
	return 1;
}
