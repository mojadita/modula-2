/* brule.h --- definition of bnf_rule_t
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Fri Jun 15 00:43:28 EEST 2018
 */
#ifndef BRULE_H
#define BRULE_H

#include "ebnfp.h"

typedef struct bnf_rule {
	size_t					  r_ref_count;
    const_bnf_token_t         r_nonterminal_ident;
    bnf_alternative_set_t	  r_right_side;
} *bnf_rule_t;

bnf_rule_t
bnf_rule(
		const_bnf_token_t nonterm_identifier,
		bnf_alternative_set_t right_side);

#endif /* BRULE_H */
