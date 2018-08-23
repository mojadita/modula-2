%{
/* m2l.l -- lexical analyser for MODULA-2.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Wed May  9 08:03:51 EEST 2018
 */

#include <stdio.h>
#include <string.h>
#include "m2p.h"

#define SYMBOL			(yytext[0])
#define RESERVED_WORD	(p->token_val)
#define RETURN(tok) do {                                \
			printf(F("\033[37m" #tok "\033[33m(%d)\033[37m <\033[36m%s\033[37m>\033[m\n"), tok, yytext); \
			return tok;                                 \
		} while(0)

%}
%option noyywrap

ident	[a-zA-Z$][a-zA-Z0-9$]*
oint	[0-7][0-7]*B
dint	[0-9][0-9]*
hint	[0-9][0-9A-F]*H
integer	({oint}|{dint}|{hint})
sf		E[+-]?{dint}
real	{dint}"."[0-9]*({sf})?
c1		\"[^\"\n]\"
c2		\'[^\'\n]\'
c3		[0-7][0-7]*C
s1		\"[^\"\n][^\"\n]+\"
s2		\'[^\'\n][^\'\n]+\'
chr		({c1}|{c2}|{c3})
string	({s1}|{s2})

%%

{ident}		{
				const struct res_word *p = rw_lookup(yytext);
				if (p) RETURN(RESERVED_WORD);
				RETURN(IDENT);
			}
{integer}	|
{real}		RETURN(NUMBER);
{string}	RETURN(STRING);
{chr}		RETURN(CHARLIT);
":="		RETURN(ASSIGN);
"<>"		RETURN(NE);
"<="		RETURN(LE);
">="		RETURN(GE);
".."		RETURN(RANGE);
\n			|
" "			|
\t			;
.			RETURN(SYMBOL);

%%

static const struct res_word res_word_tab[] = {
#define TOKEN(nam, pfx) { pfx##nam, #nam },
#include "m2p.i"
#undef TOKEN
};
static const size_t res_word_tabsz = sizeof res_word_tab / sizeof res_word_tab[0];

static int rw_cmp(const void *a, const void *b)
{
	const struct res_word *pa = a, *pb = b;
	return strcmp(pa->lexem, pb->lexem);
}

const struct res_word *rw_lookup(const char *name)
{
	struct res_word key = { .lexem = name, };
	return bsearch(&key,
		res_word_tab, res_word_tabsz, sizeof(res_word_tab[0]),
		rw_cmp);
}
