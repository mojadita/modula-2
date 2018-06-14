/* bterm.h -- ebnf_term_t definitions.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Thu Jun 14 21:36:21 EEST 2018
 */
#ifndef BTERM_H
#define BTERM_H

#define T_IDENT     (0) /* identifier terminal */
#define T_REPTD     (2) /* repeated subexpression */
#define T_OPTNL     (3) /* optional subexpression */
#define T_PAREN     (4) /* parenthesized subexpression */
#define T_STRNG		(5) /* string terminal (reserved word/symbol) */

typedef struct bnf_term {
	size_t					  	  t_ref_count;
    int                 	  	  t_type;
    union {
		const_bnf_token_t	  	  u_strng;
        struct {
            const_bnf_token_t 	  v_ident;
            const_bnf_rule_t  	  v_rule;
        } v;
        bnf_alternative_set_t     u_reptd;
        bnf_alternative_set_t     u_optnl;
        bnf_alternative_set_t     u_paren;
    } u;
#define t_strng     u.u_strng
#define t_ident     u.v.v_ident
#define t_reptd     u.u_reptd
#define t_optnl     u.u_optnl
#define t_paren     u.u_paren
#define t_rule		u.v.v_rule
} *bnf_term_t;

bnf_term_t bnf_term_ident(const_bnf_token_t ident);

bnf_term_t bnf_term_string(const_bnf_token_t string);

bnf_term_t bnf_term_reptd(bnf_alternative_set_t reptd);

bnf_term_t bnf_term_optnl(bnf_alternative_set_t optnl);

bnf_term_t bnf_term_paren(bnf_alternative_set_t paren);

#endif /* BTERM_H */
