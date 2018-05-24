/* tree.c -- parse tree construction primitives.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Tue May 15 09:39:12 EEST 2018
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <avl.h>

#include "const.h"

#ifndef DEBUG
#define DEBUG (0)
#endif

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

const_bnf_grammar_t bnf_grammar(const_bnf_grammar_t left, const_bnf_rule_t rule)
{
    bnf_grammar_t res = malloc(sizeof *res);
    assert(res != NULL);
    res->g_head_grammar = left; res->g_tail_rule = rule;
    PR2(left, rule);
    return res;
} /* bnf_grammar */

const_bnf_rule_t bnf_rule(const_bnf_token_t ident, const_bnf_right_side_t right_side)
{
    bnf_rule_t res = malloc(sizeof *res);
    assert(res != NULL);
    res->r_name = ident; res->r_right_side = right_side;
    PR2(ident, right_side);
    return res;
} /* bnf_rule */

const_bnf_right_side_t bnf_right_side(const_bnf_right_side_t left, const_bnf_alternative_t altern)
{
    bnf_right_side_t res = malloc(sizeof *res);
    assert(res != NULL);
    res->rs_head_right_side = left; res->rs_tail_alternative = altern;
    PR2(left, altern);
    return res;
} /* bnf_right_side */

const_bnf_right_side_t bnf_concat_right_sides(const_bnf_right_side_t left, const_bnf_right_side_t right)
{
    /* first search for the leftmost reference of the right rigt_side */
    bnf_right_side_t aux = (bnf_right_side_t) right;
    while(aux->rs_head_right_side)
        aux = (bnf_right_side_t) aux->rs_head_right_side;
    aux->rs_head_right_side = left;
    return right;
} /* bnf_concat_right_sides */

static AVL_TREE alternative_db = NULL;

static int bnf_alternative_cmp(const_bnf_alternative_t a, const_bnf_alternative_t b)
{
	int res = a->a_head_alternative - b->a_head_alternative;
    if (res != 0) return res;
    else return a->a_tail_term - b->a_tail_term;
} /* bnf_alternative_cmp */

static void alternative_init_db(void)
{
    if (!alternative_db) {
        alternative_db = new_avl_tree(
                (AVL_FCOMP) bnf_alternative_cmp,
                NULL, NULL, NULL);
    }
} /* alternative_init_db */

const_bnf_alternative_t bnf_alternative(const_bnf_alternative_t left, const_bnf_term_t right)
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
    }
    PR2(left, right);
    return res;
} /* bnf_alternative */

static AVL_TREE term_db = NULL;

static int bnf_term_cmp(const_bnf_term_t a, const_bnf_term_t b)
{
	int aux = a->t_type - b->t_type;
    if (aux != 0) return aux;
    switch(a->t_type) {
    case T_IDENT:
        return a->t_ident - b->t_ident;
    case T_NONTERM:
        aux = a->t_ident - b->t_ident;
        if (aux != 0) return aux;
        return a->t_rule - b->t_rule;
    case T_REPTD:
        return a->t_reptd - b->t_reptd;
    case T_OPTNL:
        return a->t_optnl - b->t_optnl;
    case T_PAREN:
        return a->t_paren - b->t_paren;
    case T_STRNG:
        return a->t_strng - b->t_strng;
    default:
        fprintf(stderr,
                F("Internal error: bnf_term.t_type "
                    "must be one of T_IDENT, "
                    "T_NONTERM, T_REPETD, T_OPTNL, "
                    "T_PAREN or T_STRNG. (Was %d)"),
                a->t_type);
        exit(EXIT_FAILURE);
    } /* switch */
} /* bnf_term_cmp */

const_bnf_term_t bnf_term_copy(bnf_term_t old)
{
    bnf_term_t res = malloc(sizeof *res);
    assert(res != NULL);
    *res = *old;
    return res;
} /* bnf_term_copy */

static void init_term_db(void)
{
	if (!term_db) {
        term_db = new_avl_tree(
            (AVL_FCOMP) bnf_term_cmp,
            (AVL_FCONS) bnf_term_copy,
            (AVL_FDEST) free,
            NULL);
    }
} /* init_term_db */

const_bnf_term_t bnf_term_ident(const_bnf_token_t ident)
{
    init_term_db();
    struct bnf_term aux;
    memset(&aux, 0, sizeof aux);
    aux.t_type = T_IDENT;
    aux.t_ident = ident;
    const struct bnf_term * res = avl_tree_get(term_db, &aux);
    if (!res) {
        AVL_ITERATOR it = avl_tree_put(term_db, &aux, NULL);
        avl_iterator_set_data(it, res = avl_iterator_key(it));
    }
    PR1(ident);
    return res;
} /* bnf_term_ident */

const_bnf_term_t bnf_term_string(const_bnf_token_t string)
{
    init_term_db();
    struct bnf_term aux;
    memset(&aux, 0, sizeof aux);
    aux.t_type = T_STRNG;
    aux.t_strng = string;
    const struct bnf_term * res = avl_tree_get(term_db, &aux);
    if (!res) {
        AVL_ITERATOR it = avl_tree_put(term_db, &aux, NULL);
        avl_iterator_set_data(it, res = avl_iterator_key(it));
    }
    PR1(string);
    return res;
} /* bnf_term_string */

const_bnf_term_t bnf_term_reptd(const_bnf_right_side_t reptd)
{
    init_term_db();
    struct bnf_term aux;
    memset(&aux, 0, sizeof aux);
    aux.t_type = T_REPTD;
    aux.t_reptd = reptd;
    const struct bnf_term * res = avl_tree_get(term_db, &aux);
    if (!res) {
        AVL_ITERATOR it = avl_tree_put(term_db, &aux, NULL);
        avl_iterator_set_data(it, res = avl_iterator_key(it));
    }
    PR1(reptd);
    return res;
} /* bnf_term_reptd */

const_bnf_term_t bnf_term_optnl(const_bnf_right_side_t optnl)
{
    init_term_db();
    struct bnf_term aux;
    memset(&aux, 0, sizeof aux);
    aux.t_type = T_OPTNL;
    aux.t_optnl = optnl;
    const struct bnf_term *res = avl_tree_get(term_db, &aux);
    if (!res) {
        AVL_ITERATOR it = avl_tree_put(term_db, &aux, NULL);
        avl_iterator_set_data(it, res = avl_iterator_key(it));
    }
    PR1(optnl);
    return res;
} /* bnf_term_optnl */

const_bnf_term_t bnf_term_paren(const_bnf_right_side_t paren)
{
    init_term_db();
    struct bnf_term aux;
    memset(&aux, 0, sizeof aux);
    aux.t_type = T_PAREN;
    aux.t_paren = paren;
    const struct bnf_term * res = avl_tree_get(term_db, &aux);
    if (!res) {
        AVL_ITERATOR it = avl_tree_put(term_db, &aux, NULL);
        avl_iterator_set_data(it, res = avl_iterator_key(it));
    }
    PR1(paren);
    return res;
} /* bnf_term_paren */
