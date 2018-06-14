/* bterm.c -- ebnf_term_t routines.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Thu Jun 14 21:23:16 EEST 2018
 */

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ebnfp.h"

#include "bterm.h"

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

static AVL_TREE term_db = NULL;

static int bnf_term_cmp(const_bnf_term_t a, const_bnf_term_t b)
{
	int aux = a->t_type - b->t_type;
    if (aux != 0) return aux;
    switch(a->t_type) {
    case T_IDENT:
        return a->t_ident - b->t_ident;
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

static bnf_term_t bnf_term_copy(bnf_term_t old)
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

bnf_term_t bnf_term_ident(const_bnf_token_t ident)
{
    init_term_db();
    struct bnf_term aux;
    memset(&aux, 0, sizeof aux);
    aux.t_type = T_IDENT;
    aux.t_ident = ident;
    bnf_term_t res = avl_tree_get(term_db, &aux);
    if (!res) {
        AVL_ITERATOR it = avl_tree_put(term_db, &aux, NULL);
        avl_iterator_set_data(it, res = (bnf_term_t) avl_iterator_key(it));
    	PR1(ident);
    }
    return res;
} /* bnf_term_ident */

bnf_term_t bnf_term_string(const_bnf_token_t string)
{
    init_term_db();
    struct bnf_term aux;
    memset(&aux, 0, sizeof aux);
    aux.t_type = T_STRNG;
    aux.t_strng = string;
    bnf_term_t res = avl_tree_get(term_db, &aux);
    if (!res) {
        AVL_ITERATOR it = avl_tree_put(term_db, &aux, NULL);
        avl_iterator_set_data(it, res = (bnf_term_t)avl_iterator_key(it));
		PR1(string);
    }
    return res;
} /* bnf_term_string */

bnf_term_t bnf_term_reptd(bnf_alternative_set_t reptd)
{
    init_term_db();
    struct bnf_term aux;
    memset(&aux, 0, sizeof aux);
    aux.t_type = T_REPTD;
    aux.t_reptd = reptd;
    bnf_term_t res = avl_tree_get(term_db, &aux);
    if (!res) {
        AVL_ITERATOR it = avl_tree_put(term_db, &aux, NULL);
        avl_iterator_set_data(it, res = (bnf_term_t) avl_iterator_key(it));
    	PR1(reptd);
    }
    return res;
} /* bnf_term_reptd */

bnf_term_t bnf_term_optnl(bnf_alternative_set_t optnl)
{
    init_term_db();
    struct bnf_term aux;
    memset(&aux, 0, sizeof aux);
    aux.t_type = T_OPTNL;
    aux.t_optnl = optnl;
    bnf_term_t res = avl_tree_get(term_db, &aux);
    if (!res) {
        AVL_ITERATOR it = avl_tree_put(term_db, &aux, NULL);
        avl_iterator_set_data(it, res = (bnf_term_t) avl_iterator_key(it));
    	PR1(optnl);
    }
    return res;
} /* bnf_term_optnl */

bnf_term_t bnf_term_paren(bnf_alternative_set_t paren)
{
    init_term_db();
    struct bnf_term aux;
    memset(&aux, 0, sizeof aux);
    aux.t_type = T_PAREN;
    aux.t_paren = paren;
    bnf_term_t res = avl_tree_get(term_db, &aux);
    if (!res) {
        AVL_ITERATOR it = avl_tree_put(term_db, &aux, NULL);
        avl_iterator_set_data(it, res = (bnf_term_t) avl_iterator_key(it));
		PR1(paren);
    }
    return res;
} /* bnf_term_paren */
