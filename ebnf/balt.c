/* balt.c -- implementation of bnf_alternative_t
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Thu Jun 14 22:52:08 EEST 2018
 */

#include <stdlib.h>
#include <assert.h>

#include "balt.h"

#define PR(a,b) do{								            \
		if (main_flags & FLAG_TRACE_SYNTREE)	            \
			printf(F("%sbnf_alternative%s:\n"               \
                     "  ref_count: %u\n"                    \
                     "  " #a ": %p\n"                       \
                     "  " #b ": %p\n"                       \
                     "  ==> %p;\n"),		                \
                res->a_ref_count == 1 ? "\033[1;32m" : "",  \
                res->a_ref_count == 1 ? "\033[m" : "",      \
				res->a_ref_count, a, b, res);               \
	} while(0)

static AVL_TREE bnf_alternatives_db = NULL;

static int
bnf_alternative_cmp(
        const_bnf_alternative_t lft,
        const_bnf_alternative_t rgt)
{
	int res = (char *)lft->a_head_alternative - (char *)rgt->a_head_alternative;
    if (res != 0) return res;
    return (char *)lft->a_tail_term - (char *)rgt->a_tail_term;
} /* bnf_alternative_cmp */

static void
alternative_init_db(void)
{
    if (!bnf_alternatives_db) {
        bnf_alternatives_db = new_avl_tree(
                (AVL_FCOMP) bnf_alternative_cmp,
                NULL, NULL, NULL);
        assert(bnf_alternatives_db != NULL);
    }
} /* alternative_init_db */

bnf_alternative_t bnf_alternative_lookup(bnf_alternative_t head, bnf_term_t tail)
{
    alternative_init_db();

    struct bnf_alternative key;
    key.a_ref_count = 0;
    key.a_head_alternative = head;
    key.a_tail_term = tail;
    return avl_tree_get(bnf_alternatives_db, &key);
} /* bnf_alternative_lookup */

bnf_alternative_t
bnf_alternative(
        bnf_alternative_t alt,
        bnf_term_t term)
{
    bnf_alternative_t res = bnf_alternative_lookup(alt, term);
    if (!res) {
        /* doesn't exist */
        res = malloc(sizeof *res);
        assert(res != NULL);

        res->a_ref_count = 0;
        res->a_head_alternative = alt;
        res->a_tail_term = term;

        avl_tree_put(bnf_alternatives_db, res, res);
    }

    res->a_ref_count++;
	PR(alt, term);

    return res;
} /* bnf_alternative */
