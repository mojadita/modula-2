/* ebnfp.h -- structures and unions for the ebnf parser.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Tue May 15 07:52:14 EEST 2018
 */
#ifndef EBNFP_H
#define EBNFP_H

#include <avl.h>
#include "const.h"
#include "ebnfs.h"

#define TYPE(tok) 											\
	typedef struct bnf_##tok *bnf_##tok##_t;				\
	typedef const struct bnf_##tok *const_bnf_##tok##_t;

TYPE(grammar)
TYPE(rule)
TYPE(alternative_set)
TYPE(alternative)
TYPE(term)

extern bnf_grammar_t bnf_main_grammar;

#undef TYPE

#endif /* EBNFP_H */
