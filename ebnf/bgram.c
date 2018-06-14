/* bgram.c -- implementation of bnf_grammar_t
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Fri Jun 15 00:54:44 EEST 2018
 */

#include <assert.h>
#include <avl.h>

bnf_grammar_t bnf_grammar(bnf_grammar_t grammar, bnf_rule_t rule)
{
	/* we do require a valid rule, as a grammar has to have at least
	 * one rule. */
	assert(rule != NULL);

	if (!grammar) {
		/* we have no grammar yet, create one and populate it up */
		grammar = new_avl_tree(
			(AVL_FCOMP) strcmp,
			(AVL_FCONS) NULL,
			(AVL_FDEST) NULL,
			(AVL_FPRNT) fputs); /* for debugging purposes. */
	}

	/* look for a rule in grammar with identifier like the one pas sed and
	 * add all the alternatives there, if we find the rule, freeing the
	 * original if we found a rule.  Or register the passed rule i nto
	 * the grammar, if we don't find it. */ 
	bnf_rule_t db_rule = avl_tree_get(grammar, rule->r_nonterminal_ident);
	if (db_rule) { /* found */
        db_rule->r_ref_count++; /* one more reference to this rule */
        printf(F("A rule with name %s has been found in grammar, making its ref_count to reach %d\n"),
                db_rule->r_nonterminal_ident,
                db_rule->r_ref_count);
		/* add all the alternatives in the presented rule to the one in database */
		AVL_ITERATOR it;
        /* for each alternative in presented rule list */
		for (it = avl_tree_first(rule->r_alternative_list); it; it = avl_iterator_next(it)) {
            bnf_alternative_list_t presented_alt = avl_iterator_data(it);
            /* if the alternative doesn't exist in the found rule, add it */
            if (!avl_tree_has(db_rule->r_alternative_list, presented_alt)) {
                avl_tree_put(db_rule->r_alternative_list, presented_alt, presented_alt);
                presented_alt->a_ref_count;
            }        
        }
	} else { /* no rule, install it */
		avl_tree_put(grammar, rule->r_nonterminal_ident, rule);
	}
    bnf_grammar_t res = new_avl_tree(
            (AVL_FCOMP) strcmp,
            (AVL_FCONS) NULL,
            (AVL_FDEST) NULL,
            (AVL_FPRNT) fputs);
    assert(res != NULL);
    res->g_head_grammar = grammar; res->g_tail_rule = rule;
    PR2(grammar, rule);
    return res;
} /* bnf_grammar */
