/* balts.c -- implementation of bnf_alternative_set_t
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Fri Jun 15 00:14:07 EEST 2018
 */

#include <assert.h>
#include <stdlib.h>

#define PR2(a,b) do{							\
		if (main_flags & FLAG_TRACE_SYNTREE)	\
			printf(F(#a ": %p, " #b				\
					": %p ==> %p;\n"),			\
				a, b, res);						\
	} while(0)

#define PR1(a) do{								\
		if (main_flags & FLAG_TRACE_SYNTREE)	\
			printf(F(#a ": %p ==> %p;\n"),		\
				a, res);						\
	} while(0)

#include "ebnfp.h"

#include "balts.h"

bnf_alternative_set_t
bnf_alternative_set(
		bnf_alternative_set_t	left,
		bnf_alternative_t		altern)
{
    bnf_alternative_set_t res = malloc(sizeof *res);
    assert(res != NULL);
    res->rs_head_right_side = left; res->rs_tail_alternative = altern;
    PR2(left, altern);
    return res;
} /* bnf_alternative_set */

bnf_alternative_list_t
bnf_merge_alternative_sets(
		bnf_alternative_set_t	left,
		bnf_alternative_set_t	right)
{
    /* first search for the leftmost reference of the right rigt_side */
    bnf_alternative_list_t aux = right;
    while(aux->rs_head_right_side)
        aux = aux->rs_head_right_side;
    aux->rs_head_right_side = left;
    return right;
} /* bnf_merge_alternative_sets */
