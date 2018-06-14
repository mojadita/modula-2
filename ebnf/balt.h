/* balt.h -- definitions for bnf_alternative_t
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Thu Jun 14 22:46:54 EEST 2018
 */
#ifndef BALT_H
#define BALT_H

#include "ebnfp.h"

typedef struct bnf_alternative {
	size_t					  a_ref_count;
	const_bnf_alternative_t	  a_head_alternative;
	const_bnf_term_t		  a_tail_term;
} *bnf_alternative_t;

bnf_alternative_t bnf_alternative(bnf_alternative_t head, bnf_term_t tail);

#endif /* BALT_H */
