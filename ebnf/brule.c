/* brule.c -- implementation of bnf_rule_t
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Fri Jun 15 00:33:45 EEST 2018
 */

#include "brule.h"

bnf_rule_t
bnf_rule(
		bnf_token_t				ident,
		bnf_alternative_list_t	right_side)
{
    bnf_rule_t res = malloc(sizeof *res);
    assert(res != NULL);
    res->r_name = ident; res->r_right_side = right_side;
    PR2(ident, right_side);
    return res;
} /* bnf_rule */
