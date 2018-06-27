/* bgram.h --- definitions for bnf_grammar_t
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Fri Jun 15 00:49:35 EEST 2018
 */
#ifndef BGRAM_H
#define BGRAM_H

#include <stdio.h>
#include "ebnfp.h"

typedef struct bnf_grammar {
    size_t                    g_ref_count;
    AVL_TREE                  g_rules;
} *bnf_grammar_t;

bnf_grammar_t
bnf_grammar(
		bnf_grammar_t	grammar,
		bnf_rule_t		rule);
size_t
bnf_grammar_print(FILE *out, bnf_grammar_t gram);

#endif /* BGRAM_H */
