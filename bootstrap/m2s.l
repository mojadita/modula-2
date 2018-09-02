%{
/* m2l.l -- lexical analyser for MODULA-2.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Wed May  9 08:03:51 EEST 2018
 */

#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <avl.h>

#include "global.h"
#include "m2p.h"

#define SYMBOL			(yytext[0])
#define RESERVED_WORD	(p->token_val)
#define RETURN(tok) do {                                	\
			if (global.flags & GL_FLAG_VERBOSE_SCANNER)		\
				printf(F("\033[37m" #tok "\033[33m(%d)\033"	\
					"[37m <\033[36m%s\033[37m>\033[m\n"),	\
					tok, yytext);							\
			return tok;                                 	\
		} while(0)

static const char *intern(const char *s);
static const char *de_escape(char *s);
static const struct res_word *rw_lookup(const char *name);

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
				if (p) {
					yylval.string = p->lexem;
					RETURN(RESERVED_WORD);
				}
				/* TODO: check for module names to return MOD_IDENT */
				yylval.string = intern(yytext);
				RETURN(IDENT);
			}
{dint}/".."	|
{integer}	{
				yylval.integer = atoi(yytext);
				RETURN(INTEGER);
			}
{real}		{
				sscanf(yytext, "%lg", &yylval.real);
				RETURN(REAL);
			}
{string}	{
				yylval.string = de_escape(yytext);
				RETURN(STRING);
			}
{chr}		{
				yylval.integer = yytext[0];
				RETURN(CHARLIT);
			}
":="		{
				yylval.string = ":=";
				RETURN(ASSIGN);
			}
"<>"		{
				yylval.string = "<>";
				RETURN(NE);
			}
"<="		{
				yylval.string = "<=";
				RETURN(LE);
			}
">="		{
				yylval.string = ">=";
				RETURN(GE);
			}
".."		{
				yylval.string = "..";
				RETURN(RANGE);
			}
\n			|
" "			|
\t			;
.			{
				yylval.string = intern(yytext);
				RETURN(SYMBOL);
			}

%%

static const struct res_word res_word_tab[] = {
#define TOKEN(nam, pfx) { pfx##nam, #nam },
#include "token.i"
#undef TOKEN
};
static const size_t res_word_tabsz = sizeof res_word_tab / sizeof res_word_tab[0];

static int rw_cmp(const void *a, const void *b)
{
	const struct res_word *pa = a, *pb = b;
	return strcmp(pa->lexem, pb->lexem);
}

static const struct res_word *rw_lookup(const char *name)
{
	struct res_word key = { .lexem = name, };
	return bsearch(&key,
		res_word_tab, res_word_tabsz, sizeof(res_word_tab[0]),
		rw_cmp);
}

static const char *de_escape(char *s)
{
	s = strdup(s);
	char *p = s + strlen(s);
	*--p = 0;
	const char *res = intern(s+1);
	free(s);
	return res;
}

static const char *intern(const char *s)
{
	static AVL_TREE id_lexemes;
	if (!id_lexemes) {
		id_lexemes = new_avl_tree(
			(AVL_FCOMP)strcmp, (AVL_FCONS)0,
			(AVL_FDEST)0, (AVL_FPRNT)0);
	}
	char *result = avl_tree_get(id_lexemes, s);
	if (!result) {
		result = strdup(s);
		assert(result != 0);
		avl_tree_put(id_lexemes, result, result);
	}
	return result;
}
