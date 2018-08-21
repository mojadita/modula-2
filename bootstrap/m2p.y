%{
/* m2p.y -- parser for MODULA-2.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Tue Aug 21 08:10:26 EEST 2018
 * Based on the MODULA-2 report by N. Wirth, 1978.
 * See: https://doi.org/10.3929/ethz-a-000153014
 */

#include <string.h>
#include <stdlib.h>

#include "m2p.h"
%}

%token AND ARRAY TBEGIN BY CASE CONST DEFINITION DIV DO ELSE ELSIF
%token END EXIT EXPORT FOR FROM IF IMPORT IN LOOP MOD MODULE NOT
%token OF OR POINTER PROCEDURE QUALIFIED RECORD REPEAT TRETURN
%token SET THEN TO TYPE UNTIL VAR WHILE WITH

%token ASSIGN LE GE DOTDOT

/* this token is returned when an error is detected in the
 * scanner. */
%token BAD_TOKEN

%%

compilation: TBEGIN END;

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
	printf("rw_lookup(%s)\n", name);
	return bsearch(name,
		res_word_tab, res_word_tabsz, sizeof(*res_word_tab),
		rw_cmp);
}
