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

#define PR(t, tstr, a) do{                      \
		if (main_flags & FLAG_TRACE_SYNTREE)	\
            printf(F("type: " tstr "(%d)\n"),   \
                    t);                         \
			printf(F(#a ": %p ==> %p;\n"),		\
				a, res);						\
	} while(0)

static AVL_TREE bnf_term_db = NULL;

static int bnf_term_cmp(const_bnf_term_t lft, const_bnf_term_t rgt)
{
	int aux = lft->t_type - rgt->t_type;
    if (aux != 0) return aux;
    switch(lft->t_type) {
    case T_IDENT:
        return (char *)lft->t_ident - (char *)rgt->t_ident;
    case T_REPTD:
        return (char *)lft->t_reptd - (char *)rgt->t_reptd;
    case T_OPTNL:
        return (char *)lft->t_optnl - (char *)rgt->t_optnl;
    case T_PAREN:
        return (char *)lft->t_paren - (char *)rgt->t_paren;
    case T_STRNG:
        return (char *)lft->t_strng - (char *)rgt->t_strng;
    default:
        fprintf(stderr,
                F("Internal error: bnf_term.t_type "
                    "must be one of T_IDENT(%d), "
                    "T_REPTD(%d), T_OPTNL(%d), "
                    "T_PAREN(%d) or T_STRNG(%d). (Was %d)"),
                T_IDENT, T_REPTD, T_OPTNL, T_PAREN, T_STRNG,
                lft->t_type);
        exit(EXIT_FAILURE);
    } /* switch */
} /* bnf_term_cmp */

static void
init_term_db(void)
{
	if (!bnf_term_db) {
        bnf_term_db = new_avl_tree(
            (AVL_FCOMP) bnf_term_cmp,
            (AVL_FCONS) NULL,
            (AVL_FDEST) NULL,
            (AVL_FPRNT) NULL);
        assert(bnf_term_db != NULL);
    }
} /* init_term_db */

#define FUNCTION(name, type, flag)                    \
bnf_term_t                                            \
bnf_term_##name(                                      \
        type name)                                    \
{                                                     \
    init_term_db();                                   \
        struct bnf_term key;                          \
        key.t_type = flag;                            \
        key.t_##name = name;                          \
    bnf_term_t res = avl_tree_get(bnf_term_db, &key); \
    if (!res) {                                       \
        res = malloc(sizeof *res);                    \
        assert(res != NULL);                          \
        res->t_ref_count = 0;                         \
        res->t_type = flag;                           \
        res->t_##name = name;                         \
        avl_tree_put(bnf_term_db, res, res);          \
    }                                                 \
    res->t_ref_count++;                               \
    PR(flag, #flag, name);                            \
    return res;                                       \
}

FUNCTION(ident,  const_bnf_token_t,     T_IDENT)
FUNCTION(strng,  const_bnf_token_t,     T_STRNG)
FUNCTION(reptd,  bnf_alternative_set_t, T_REPTD)
FUNCTION(optnl,  bnf_alternative_set_t, T_OPTNL)
FUNCTION(paren,  bnf_alternative_set_t, T_PAREN)

#undef FUNCTION
