/* ebnfp.h -- structures and unions for the ebnf parser.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Tue May 15 07:52:14 EEST 2018
 */
#ifndef EBNFP_H
#define EBNFP_H

#include "const.h"
#include "ebnfs.h"

#define TYPE(tok) 											\
	typedef struct bnf_##tok *bnf_##tok##_t;				\
	typedef const struct bnf_##tok *const_bnf_##tok##_t;
TYPE(grammar)
TYPE(rule)
TYPE(right_side)
TYPE(alternative)
TYPE(term)
#undef TYPE

typedef struct bnf_grammar {
    const_bnf_grammar_t       g_head_grammar;
    const_bnf_rule_t          g_tail_rule;
} *bnf_grammar_t;

typedef struct bnf_rule {
    const_bnf_token_t         r_name;
    const_bnf_right_side_t    r_right_side;
} *bnf_rule_t;

typedef struct bnf_right_side {
    const_bnf_right_side_t   		rs_head_right_side;
    const_bnf_alternative_t       rs_tail_alternative;
} *bnf_right_side_t;

typedef struct bnf_alternative {
	const_bnf_alternative_t		a_head_alternative;
	const_bnf_term_t				a_tail_term;
} *bnf_alternative_t;

#define T_IDENT     (0) /* identifier terminal */
#define T_NONTERM	(1) /* defined nonterminal */
#define T_REPTD     (2) /* repeated subexpression */
#define T_OPTNL     (3) /* optional subexpression */
#define T_PAREN     (4) /* parenthesized subexpression */
#define T_STRNG		(5) /* string terminal (reserved word/symbol) */

typedef struct bnf_term {
    int                 t_type;
    union {
		const_bnf_token_t			u_strng;
        struct {
            const_bnf_token_t     u_ident;
            const_bnf_rule_t		u_rule;
        } v;
        const_bnf_right_side_t    u_reptd;
        const_bnf_right_side_t    u_optnl;
        const_bnf_right_side_t    u_paren;
    } u;
#define t_strng     u.u_strng
#define t_ident     u.v.u_ident
#define t_reptd     u.u_reptd
#define t_optnl     u.u_optnl
#define t_paren     u.u_paren
#define t_rule		u.v.u_rule
} *bnf_term_t;

const_bnf_grammar_t bnf_grammar(
        const_bnf_grammar_t left,
        const_bnf_rule_t rule);

const_bnf_rule_t bnf_rule(
        const_bnf_token_t ident,
        const_bnf_right_side_t right_side);

const_bnf_right_side_t bnf_right_side(
        const_bnf_right_side_t left,
        const_bnf_alternative_t altern);

const_bnf_right_side_t bnf_concat_right_sides(
		const_bnf_right_side_t left,
		const_bnf_right_side_t right);

const_bnf_alternative_t bnf_alternative(
        const_bnf_alternative_t left,
        const_bnf_term_t right);

const_bnf_term_t bnf_term_ident(
        const_bnf_token_t ident);

const_bnf_term_t bnf_term_string(
        const_bnf_token_t string);

const_bnf_term_t bnf_term_reptd(
        const_bnf_right_side_t reptd);

const_bnf_term_t bnf_term_optnl(
        const_bnf_right_side_t optnl);

const_bnf_term_t bnf_term_paren(
        const_bnf_right_side_t paren);

#endif /* EBNFP_H */
