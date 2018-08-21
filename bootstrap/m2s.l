%{
/* m2l.l -- lexical analyser for MODULA-2.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Wed May  9 08:03:51 EEST 2018
 */

#include <stdio.h>
#include "m2p.h"

#define F(fmt) __FILE__":%d:%s: " fmt, __LINE__, __func__

#define RETURN(tok) printf(F("TOKEN: " #tok ": %s\n"), yytext)

%}

ident	[a-zA-Z$][a-zA-Z0-9$]*
oint	[0-7][0-7]*[BC]
dint	[0-9][0-9]*
hint	[0-9][0-9A-F]*H
integer	({oint}|{dint}|{hint})
sf		E[+-]?{dint}
real	{dint}"."[0-9]*({sf})?
s1		\"[^\"\n]*\"
s2		\'[^\'\n]*\'
string	({s1}|{s2})

%%

{ident}		{
				printf(F("searching for %s\n"), yytext);
				const struct res_word *p = rw_lookup(yytext);
				printf(F("res = %p\n"), p);
				RETURN(p ? p->token_value : IDENT);
			}
{integer}	|
{real}		RETURN(NUMBER);
":="		RETURN(ASSIGN);
"<>"		RETURN("#");
"<="		RETURN(LE);
">="		RETURN(GE);
".."		RETURN(DOTDOT);
\n			|
" "			|
\t			;
.			RETURN(SYMBOL);

%%
