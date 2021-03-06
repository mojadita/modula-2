/* brule.c -- implementation of bnf_rule_t
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Fri Jun 15 00:33:45 EEST 2018
 */

#include <assert.h>
#include <stdlib.h>
#include "brule.h"
#include "balts.h"

bnf_rule_t
bnf_rule(
		const_bnf_token_t      ident,
		bnf_alternative_set_t  right_side)
{
    bnf_rule_t res = malloc(sizeof *res);
    assert(res != NULL);
    res->r_nonterminal_ident = ident; res->r_right_side = right_side;
    if (main_flags & FLAG_TRACE_SYNTREE)
        printf(F(" %s(ident=%s, right_side=%p)"
                 " ==> { nonterminal_ident=%s,"
                 " right_side=%p }"
                 " @ %p\n"),
                __func__,ident,right_side,
                res->r_nonterminal_ident,
                res->r_right_side,
                res);
    return res;
} /* bnf_rule */

size_t
bnf_rule_print(
        FILE *out,
        const_bnf_rule_t rule)
{
    size_t res = 0;
    res += fprintf(out, "%s : ", rule->r_nonterminal_ident);
    res += bnf_alternative_set_print(out, rule->r_right_side);
    res += fprintf(out, " ;\n");
    return res;
} /* bnf_rule_print */ 
