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
#include "balts.h"

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

static char *
bnf_type_str(
        const t_type val,
        char b[],
        size_t sz)
{
    switch(val) {
#define TTYPE(name, cnst, typ, field, fmt) case cnst: snprintf(b, sz, "%s(%d)", #cnst, cnst); break;
#include "ttype.i"
#undef TTYPE
    default: snprintf(b, sz, "<<<UNKNOWN-(%d)>>>", val); break;
    } /* switch */
    return b;
} /* bnf_type_str */

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

bnf_term_t
bnf_term_ident(const_bnf_token_t ident)
{
    init_term_db();
    struct bnf_term key;
    key.t_type = T_IDENT;
    key.u.v.v_ident = ident;
    bnf_term_t res = avl_tree_get(bnf_term_db, &key);
    if (!res) {
        res = malloc(sizeof *res);
        assert(res != NULL);
        res->t_ref_count = 0;
        res->t_type = T_IDENT;
        res->u.v.v_ident = ident;
        avl_tree_put(bnf_term_db, res, res);
    }
    if (main_flags & FLAG_TRACE_SYNTREE) {
        char b[128];
        printf(F(" %s(ident: %s) ==> {"
                 " type=%s,"
                 " ref_count=%zu,"
                 " ident=%s } @ %p\n"),
               __func__, ident,
               bnf_type_str( res->t_type, b, sizeof b),
               res->t_ref_count,
               ident, res);
    }
    return res;
} /* bnf_term_ident */

bnf_term_t
bnf_term_reptd(bnf_alternative_set_t reptd)
{
    init_term_db();
    struct bnf_term key;
    key.t_type = T_REPTD;
    key.u.u_reptd = reptd;
    bnf_term_t res = avl_tree_get(bnf_term_db, &key);
    if (!res) {
        res = malloc(sizeof *res);
        assert(res != NULL);
        res->t_ref_count = 0;
        res->t_type = T_REPTD;
        res->t_reptd = reptd;
        avl_tree_put(bnf_term_db, res, res);
    }
    if (reptd) reptd->as_ref_count++;
    if (main_flags & FLAG_TRACE_SYNTREE) {
        char b[128];
        printf(F(" %s(reptd: %p)"
                 " ==> { type=%s,"
                 " ref_count=%zu,"
                 " reptd=%p } @ %p\n"),
               __func__, reptd,
               bnf_type_str( res->t_type, b, sizeof b),
               res->t_ref_count,
               reptd, res);
    }
    return res;
} /* bnf_term_reptd */

bnf_term_t
bnf_term_optnl(bnf_alternative_set_t optnl)
{
    init_term_db();
    struct bnf_term key;
    key.t_type = T_OPTNL;
    key.u.u_optnl = optnl;
    bnf_term_t res = avl_tree_get(bnf_term_db, &key);
    if (!res) {
        res = malloc(sizeof *res);
        assert(res != NULL);
        res->t_ref_count = 0;
        res->t_type = T_OPTNL;
        res->t_optnl = optnl;
        avl_tree_put(bnf_term_db, res, res);
    }
    if (optnl) optnl->as_ref_count++;
    if (main_flags & FLAG_TRACE_SYNTREE) {
        char b[128];
        printf(F(" %s(optnl: %p)"
               " ==> { type=%s,"
               " ref_count=%zu,"
               " optnl=%p } @ %p\n"),
               __func__, optnl,
               bnf_type_str(res->t_type,
                   b, sizeof b),
               res->t_ref_count,
               optnl, res);
    }
    return res;
} /* bnf_term_optnl */

bnf_term_t
bnf_term_paren(bnf_alternative_set_t paren)
{
    init_term_db();
    struct bnf_term key;
    key.t_type = T_PAREN;
    key.t_paren = paren;
    bnf_term_t res = avl_tree_get(bnf_term_db, &key);
    if (!res) {
        res = malloc(sizeof *res);
        assert(res != NULL);
        res->t_ref_count = 0;
        res->t_type = T_PAREN;
        res->t_paren = paren;
        avl_tree_put(bnf_term_db, res, res);
    }
    if(paren) paren->as_ref_count++;
    if (main_flags & FLAG_TRACE_SYNTREE) {
        char b[128];
        printf(F(" %s(paren: %p)"
                 " ==> {type=%s,"
                 " ref_count=%zu,"
                 " paren=%p } @ %p\n"),
               __func__, paren,
               bnf_type_str(res->t_type, b, sizeof b),
               res->t_ref_count,
               paren, res);
    } return res;
} /* bnf_term_paren */

bnf_term_t
bnf_term_strng(const_bnf_token_t strng)
{
    init_term_db();
    struct bnf_term key;
    key.t_type = T_STRNG;
    key.t_strng = strng;
    bnf_term_t res = avl_tree_get(bnf_term_db, &key);
    if (!res) {
        res = malloc(sizeof *res);
        assert(res != NULL);
        res->t_ref_count = 0;
        res->t_type = T_STRNG;
        res->t_strng = strng;
        avl_tree_put(bnf_term_db, res, res);
    }
    if (main_flags & FLAG_TRACE_SYNTREE) {
        char b[128];
        printf(F(" %s(strng: %p)"
                 " ==> { type=%s,"
                 " ref_count=%zu, "
                 "strng=%p } @ %p\n"),
               __func__, strng,
               bnf_type_str(res->t_type,
                   b, sizeof b),
               res->t_ref_count,
               strng, res);
    }
    return res;
} /* bnf_term_strng */

size_t
bnf_term_print(FILE *out, const_bnf_term_t term)
{
    size_t res = 0;
    if (term) {
        switch(term->t_type) {
        case T_IDENT: res += fprintf(out, "%s", term->t_ident); break;
        case T_REPTD: res += fputs("{", out);
                      res += bnf_alternative_set_print(out, term->t_reptd);
                      res += fputs("}", out); break;
        case T_OPTNL: res += fputs("[", out);
                      res += bnf_alternative_set_print(out, term->t_optnl);
                      res += fputs("]", out); break;
        case T_PAREN: res += fputs("(", out);
                      res += bnf_alternative_set_print(out, term->t_paren);
                      res += fputs(")", out); break;
        case T_STRNG: res += fprintf(out, "%s", term->t_strng); break;
        } /* switch */
    }
    return res;
} /* bnf_term_print */
