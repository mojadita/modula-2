/* brule.c -- implementation of bnf_rule_t
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Fri Jun 15 00:33:45 EEST 2018
 */

#include <assert.h>
#include <stdlib.h>
#include "brule.h"

#define PR(a,b) do{                             \
		if (main_flags & FLAG_TRACE_SYNTREE)	\
			printf(F("bnf_rule:\n"              \
                     "  " #a ": %s\n"           \
                     "  " #b ": %p\n"           \
                     "  ==> %p;\n"),            \
				    a, b, res);				    \
	} while(0)

bnf_rule_t
bnf_rule(
		const_bnf_token_t				ident,
		bnf_alternative_set_t	right_side)
{
    bnf_rule_t res = malloc(sizeof *res);
    assert(res != NULL);
    res->r_nonterminal_ident = ident; res->r_right_side = right_side;
    if (main_flags & FLAG_TRACE_SYNTREE)
        printf(F("bnf_rule:\n"
                 "  nonterminal_ident: %s\n"
                 "  right_side: %p\n"
                 "  ==> %p;\n"),
                res->r_nonterminal_ident,
                res->r_right_side,
                res);
    return res;
} /* bnf_rule */
