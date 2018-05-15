/* ebnfp.h -- structures and unions for the ebnf parser.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Tue May 15 07:52:14 EEST 2018
 */
#ifndef EBNFP_H
#define EBNFP_H

#include "const.h"

#define TYPE(tok) typedef struct bnf_##tok *bnf_##tok##_t
TYPE(grammar);
TYPE(rule);
TYPE(right_side);
TYPE(alternative);
TYPE(term);
TYPE(token);
#undef TYPE

typedef struct bnf_grammar {
    bnf_grammar_t       b_left;
    bnf_rule_t          b_right;
} *bnf_grammar_t;

typedef struct bnf_rule {
    bnf_token_t         r_ident;
    bnf_right_side_t    r_right_side;
} *bnf_rule_t;

typedef struct bnf_right_side {
    bnf_right_side_t    rs_left;
    bnf_alternative_t   rs_altern;
} *bnf_right_side_t;

typedef struct bnf_alternative {
    bnf_alternative_t   a_left;
    bnf_term_t          a_right;
} *bnf_alternative_t;

#define T_IDENT     0
#define T_REPTD     1
#define T_OPTNL     2
#define T_PAREN     3
#define T_STRNG		4

typedef struct bnf_term {
    int                 t_type;
    union {
		bnf_token_t			u_strng;
        bnf_token_t         u_ident;
        bnf_right_side_t    u_reptd_rs;
        bnf_right_side_t    u_optnl_rs;
        bnf_right_side_t    u_paren_rs;
    } u;
#define t_strng     u.u_strng
#define t_ident     u.u_ident
#define t_reptd_rs  u.u_reptd_rs
#define t_optnl_rs  u.u_optnl_rs
#define t_paren_rs  u.u_paren_rs
} *bnf_term_t;

const bnf_grammar_t bnf_grammar(
        const bnf_grammar_t left,
        const bnf_rule_t rule);

const bnf_rule_t bnf_rule(
        const bnf_token_t ident,
        const bnf_right_side_t right_side);

const bnf_right_side_t bnf_right_side(
        const bnf_right_side_t left,
        const bnf_alternative_t altern);

const bnf_alternative_t bnf_alternative(
        const bnf_alternative_t left,
        const bnf_term_t right);

const bnf_term_t bnf_term_ident(
        const bnf_token_t ident);

const bnf_term_t bnf_term_string(
        const bnf_token_t string);

const bnf_term_t bnf_term_reptd_rs(
        const bnf_right_side_t reptd_rs);

const bnf_term_t bnf_term_optnl_rs(
        const bnf_right_side_t optnl_rs);

const bnf_term_t bnf_term_paren_rs(
        const bnf_right_side_t paren_rs);

#endif /* EBNFP_H */
