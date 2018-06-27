/* balt.c -- implementation of bnf_alternative_t
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Thu Jun 14 22:52:08 EEST 2018
 */

#include <stdlib.h>
#include <assert.h>

#include "balt.h"
#include "bterm.h"

#define PR(a,b) do{								            \
	} while(0)

static AVL_TREE bnf_alternatives_db = NULL;

static int
bnf_alternative_cmp(
        const_bnf_alternative_t lft,
        const_bnf_alternative_t rgt)
{
	int res = (char *) lft->a_head_alternative - (char *) rgt->a_head_alternative;
    if (res != 0) return res;
    return (char *) lft->a_tail_term - (char *) rgt->a_tail_term;
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
    int found = 0;

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

    if (alt) alt->a_ref_count++;
    if (term) term->t_ref_count++;

    if (main_flags & FLAG_TRACE_SYNTREE) {
        printf(F(" %s(alt=%p, term=%p)"
                 " ==> { ref_count=%zu,"
                 " head_alternative=%p,"
                 " tail_term: %p} "
                 " @ %p.\n"),
            __func__, alt, term,
            res->a_ref_count,
            res->a_head_alternative,
            res->a_tail_term,
            res);
    }

    return res;
} /* bnf_alternative */

size_t bnf_alternative_print(FILE *out, const_bnf_alternative_t alt)
{
    size_t res = 0;
    if (alt->a_head_alternative) {
        res += bnf_alternative_print(out, alt->a_head_alternative);
        if (alt->a_tail_term)
            res += fputs(" ", out);
    }
    if (alt->a_tail_term)
        res += bnf_term_print(out, alt->a_tail_term);
    return res;
} /* bnf_alternative_print */
