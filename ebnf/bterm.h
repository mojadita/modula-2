/* bterm.h -- ebnf_term_t definitions.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Thu Jun 14 21:36:21 EEST 2018
 */
#ifndef BTERM_H
#define BTERM_H

typedef enum {
#define TTYPE(name, cnst, typ, field, fmt) cnst,
#include "ttype.i"
#undef TTYPE
    T_TYPE_MAX,
} t_type;

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

#define TTYPE(name, cnst, typ, fld, fmt) bnf_term_t bnf_term_##name(typ name);
#include "ttype.i"
#undef TTYPE

size_t
bnf_term_print(FILE *out, const_bnf_term_t term);

#endif /* BTERM_H */
