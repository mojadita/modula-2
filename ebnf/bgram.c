/* bgram.c -- implementation of bnf_grammar_t
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Fri Jun 15 00:54:44 EEST 2018
 */

#include <assert.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <avl.h>

#include "ebnfp.h"
#include "bgram.h"
#include "brule.h"
#include "balts.h"


bnf_grammar_t bnf_grammar(bnf_grammar_t grammar, bnf_rule_t rule)
{
	/* we do require a valid rule, as a grammar has to have at least
	 * one rule. */
	assert(rule != NULL);
    
    bnf_grammar_t res = grammar;

	if (!res) {
		/* we have no grammar yet, create one and populate it up */
        res = malloc(sizeof *res);
        assert(res != NULL);
        res->g_ref_count = 0;
        res->g_rules = new_avl_tree(
			(AVL_FCOMP) strcmp,
			(AVL_FCONS) NULL,
			(AVL_FDEST) NULL,
			(AVL_FPRNT) NULL);
	}

	/* look for a rule in grammar with identifier like the one passed and
	 * add all the alternatives there, if we find the rule, freeing the
	 * original if we found a rule.  Or register the passed rule i nto
	 * the grammar, if we don't find it. */ 
	bnf_rule_t db_rule = avl_tree_get(res->g_rules, rule->r_nonterminal_ident);
	if (db_rule) { /* found */
        printf(F("A rule with nonterminal <%s> has been found in grammar, updating its ref_count to %d\n"),
                db_rule->r_nonterminal_ident,
                db_rule->r_ref_count);
		/* add all the alternatives in the presented rule to the one in database */
        db_rule->r_right_side = bnf_merge_alternative_sets(db_rule->r_right_side, rule->r_right_side);
	} else { /* no rule, install it */
		avl_tree_put(res->g_rules, rule->r_nonterminal_ident, db_rule = rule);
	}
    db_rule->r_ref_count++; /* one more reference to this rule */
	if (main_flags & FLAG_TRACE_SYNTREE)
			printf(F("%s(grammar=%p, rule=%p)"
                     " ==> { ref_count=%zu,"
                     " rules=%p } @ %p\n"),
                   __func__, grammar, rule,
				res->g_ref_count,
                res->g_rules,
                res);
    return res;
} /* bnf_grammar */

size_t
bnf_grammar_print(FILE *out, bnf_grammar_t gram)
{
    size_t res = 0;
    AVL_ITERATOR it;
    for(it = avl_tree_first(gram->g_rules);
            it;
            it = avl_iterator_next(it))
    {
        bnf_rule_t r = avl_iterator_data(it);
        if (res) {
            fputs("\n", out);
        }
        res += bnf_rule_print(out, r);
    }
    return res;
}
