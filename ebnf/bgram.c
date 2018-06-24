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

	if (!grammar) {
		/* we have no grammar yet, create one and populate it up */
        grammar = malloc(sizeof *grammar);
        assert(grammar != NULL);
        grammar->g_ref_count = 0;
        grammar->g_rules = new_avl_tree(
			(AVL_FCOMP) strcmp,
			(AVL_FCONS) NULL,
			(AVL_FDEST) NULL,
			(AVL_FPRNT) fputs); /* for debugging purposes. */
	}

	/* look for a rule in grammar with identifier like the one passed and
	 * add all the alternatives there, if we find the rule, freeing the
	 * original if we found a rule.  Or register the passed rule i nto
	 * the grammar, if we don't find it. */ 
	bnf_rule_t db_rule = avl_tree_get(grammar->g_rules, rule->r_nonterminal_ident);
	if (db_rule) { /* found */
        db_rule->r_ref_count++; /* one more reference to this rule */
        printf(F("A rule with nonterminal <%s> has been found in grammar, updating its ref_count to %d\n"),
                db_rule->r_nonterminal_ident,
                db_rule->r_ref_count);
		/* add all the alternatives in the presented rule to the one in database */
        db_rule->r_right_side = bnf_merge_alternative_sets(db_rule->r_right_side, rule->r_right_side);
        
	} else { /* no rule, install it */
		avl_tree_put(grammar->g_rules, rule->r_nonterminal_ident, rule);
	}
	if (main_flags & FLAG_TRACE_SYNTREE)
			printf(F("bnf_grammar:\n"
                     "  ref_count: %zu\n"
                     "  rules: %p\n"
                     "  ==> %p;\n"),
				grammar->g_ref_count,
                grammar->g_rules,
                grammar);
    return grammar;
} /* bnf_grammar */
