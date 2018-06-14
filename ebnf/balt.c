/* balt.c -- implementation of bnf_alternative_t
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Thu Jun 14 22:52:08 EEST 2018
 */

#include <stdlib.h>
#include <assert.h>

#include "balt.h"

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

static AVL_TREE alternative_db = NULL;

static int bnf_alternative_cmp(bnf_alternative_t a, bnf_alternative_t b)
{
	int res = a->a_head_alternative - b->a_head_alternative;
    if (res != 0) return res;
    return (char *) a->a_tail_term - (char *) b->a_tail_term;
} /* bnf_alternative_cmp */

static void alternative_init_db(void)
{
    if (!alternative_db) {
        alternative_db = new_avl_tree(
                (AVL_FCOMP) bnf_alternative_cmp,
                NULL, NULL, NULL);
    }
} /* alternative_init_db */

bnf_alternative_t bnf_alternative(bnf_alternative_t left, bnf_term_t right)
{
    alternative_init_db();

    /* the key to compare */
    struct bnf_alternative aux;
    aux.a_head_alternative = left;
    aux.a_tail_term = right;

    bnf_alternative_t res = avl_tree_get(alternative_db, &aux);
    if (!res) {
        res = malloc(sizeof *res);
        assert(res != NULL);
        res->a_head_alternative = left;
        res->a_tail_term = right;
        avl_tree_put(alternative_db, res, res);
		PR2(left, right);
    }
    return res;
} /* bnf_alternative */
