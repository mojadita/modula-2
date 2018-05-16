/* tree.c -- parse tree construction primitives.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Tue May 15 09:39:12 EEST 2018
 */

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#include "const.h"

#ifndef DEBUG
#define DEBUG (0)
#endif

#define PR2(a,b) do{							\
		if (main_flags & FLAG_TRACE_SYNTREE)	\
			printf(F(#a ": 0x%p, " #b			\
					": 0x%p ==> 0x%p;\n"),		\
				a, b, res);						\
	} while(0)
#define PR1(a) do{								\
		if (main_flags & FLAG_TRACE_SYNTREE)	\
			printf(F(#a ": 0x%p ==> 0x%p;\n"),	\
				a, res);						\
	} while(0)

#include "ebnfp.h"

const bnf_grammar_t bnf_grammar(const bnf_grammar_t left, const bnf_rule_t rule)
{
    bnf_grammar_t res = malloc(sizeof *res);
    assert(res != NULL);
    res->b_left = left; res->b_right = rule;
    PR2(left, rule);
    return res;
} /* bnf_grammar */

const bnf_rule_t bnf_rule(const bnf_token_t ident, const bnf_right_side_t right_side)
{
    bnf_rule_t res = malloc(sizeof *res);
    assert(res != NULL);
    res->r_ident = ident; res->r_right_side = right_side;
    PR2(ident, right_side);
    return res;
} /* bnf_rule */

const bnf_right_side_t bnf_right_side(const bnf_right_side_t left, const bnf_alternative_t altern)
{
    bnf_right_side_t res = malloc(sizeof *res);
    assert(res != NULL);
    res->rs_left = left; res->rs_altern = altern;
    PR2(left, altern);
    return res;
} /* bnf_right_side */

const bnf_alternative_t bnf_alternative(const bnf_alternative_t left, const bnf_term_t right)
{
    bnf_alternative_t res = malloc(sizeof *res);
    assert(res != NULL);
    res->a_left = left; res->a_right = right;
    PR2(left, right);
    return res;
} /* bnf_alternative */

const bnf_term_t bnf_term_ident(const bnf_token_t ident)
{
    bnf_term_t res = malloc(sizeof *res);
    assert(res != NULL);
    res->t_type = T_IDENT;
    res->t_ident = ident;
    PR1(ident);
    return res;
} /* bnf_term_ident */

const bnf_term_t bnf_term_string(const bnf_token_t string)
{
    bnf_term_t res = malloc(sizeof *res);
    assert(res != NULL);
    res->t_type = T_STRNG;
    res->t_strng = string;
    PR1(string);
    return res;
} /* bnf_term_string */

const bnf_term_t bnf_term_reptd_rs(const bnf_right_side_t reptd_rs)
{
    bnf_term_t res = malloc(sizeof *res);
    assert(res != NULL);
    res->t_type = T_REPTD;
    res->t_reptd_rs = reptd_rs;
    PR1(reptd_rs);
    return res;
}

const bnf_term_t bnf_term_optnl_rs(const bnf_right_side_t optnl_rs)
{
    bnf_term_t res = malloc(sizeof *res);
    assert(res != NULL);
    res->t_type = T_OPTNL;
    res->t_optnl_rs = optnl_rs;
    PR1(optnl_rs);
    return res;
} /* bnf_term_optnl_rs */

const bnf_term_t bnf_term_paren_rs(const bnf_right_side_t paren_rs)
{
    bnf_term_t res = malloc(sizeof *res);
    assert(res != NULL);
    res->t_type = T_PAREN;
    res->t_paren_rs = paren_rs;
    PR1(paren_rs);
    return res;
} /* bnf_term_paren_rs */
