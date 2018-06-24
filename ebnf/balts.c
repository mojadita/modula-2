/* balts.c -- implementation of bnf_alternative_set_t
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Fri Jun 15 00:14:07 EEST 2018
 */

#include <assert.h>
#include <stdlib.h>
#include <avl.h>

#define PR(a,b) do{							    \
		if (main_flags & FLAG_TRACE_SYNTREE)	\
			printf(F("bnf_alternative:\n"       \
                     "  " #a ": %p\n"           \
                     "  " #b ": %p\n"	        \
					 "  ==> %p;\n"),			\
				a, b, left);				    \
	} while(0)

#include "ebnfp.h"

#include "balt.h"
#include "balts.h"

static int
bnf_alternative_cmp(
        bnf_alternative_t left,
        bnf_alternative_t right)
{
    return (char *)left - (char *)right;
} /* bnf_alternative_cmp */

static AVL_TREE bnf_alternative_sets_db;

static int
bnf_alternative_set_cmp(
		bnf_alternative_set_t left,
		bnf_alternative_set_t right)
{
    return (char *)left->as_set - (char *)right->as_set;
} /* bnf_alternative_set_cmp */

static void
bnf_alternative_set_initdb(void)
{
	if (!bnf_alternative_sets_db) {
		bnf_alternative_sets_db = new_avl_tree(
			(AVL_FCOMP) bnf_alternative_set_cmp,
			(AVL_FCONS) NULL,
			(AVL_FDEST) NULL,
			(AVL_FPRNT) NULL);
		assert(bnf_alternative_sets_db != NULL);
        printf(F("Creating database of bnf_alternative_set_t = %p\n"),
                bnf_alternative_sets_db);
	}
} /* bnf_alternative_set_initdb */

bnf_alternative_set_t
bnf_alternative_set_lookup(AVL_TREE set)
{
	bnf_alternative_set_initdb();
	struct bnf_alternative_set key;
    key.as_ref_count = 0;
    key.as_flags = 0;
    key.as_set = set;
    return avl_tree_get(bnf_alternative_sets_db, set);
} /* bnf_alternative_set_lookup */

bnf_alternative_set_t bnf_alternative_set_intern(bnf_alternative_set_t set)
{
    bnf_alternative_set_t res = bnf_alternative_set_lookup(set->as_set);
    if (!res) {
        avl_tree_put(bnf_alternative_sets_db, (const void *)(set), (void *)set);
    }
    if (set != res) free(set);
    res->as_ref_count++;
    return res;
} /* bnf_alternative_set_intern */

bnf_alternative_set_t
bnf_alternative_set(
		bnf_alternative_set_t	left,
		bnf_alternative_t		altern)
{
    if (!left) {
        left = malloc(sizeof *left);
        assert(left != NULL);
        left->as_ref_count = 1;
        left->as_set = new_avl_tree(
                (AVL_FCOMP) bnf_alternative_cmp,
                (AVL_FCONS) NULL,
                (AVL_FDEST) NULL,
                (AVL_FPRNT) NULL);
		bnf_alternative_set_initdb();
		avl_tree_put(bnf_alternative_sets_db, left, left);
    }
    if (altern) {
        bnf_alternative_t aux = avl_tree_get(left->as_set, altern);
        if (!aux) { /* alternative not found, need to add it */
            altern->a_ref_count++;
            avl_tree_put(left->as_set, altern, altern);
        }
    }

    PR(left, altern);
    return left;
} /* bnf_alternative_set */

bnf_alternative_set_t
bnf_merge_alternative_sets(
		bnf_alternative_set_t	left,
		bnf_alternative_set_t	right)
{
    /* add all the right alternatives to the left */
    AVL_ITERATOR it;
    assert(left != NULL && right != NULL);

    for (it = avl_tree_first(right->as_set); it; it = avl_iterator_next(it)) {
        bnf_alternative_t alt = avl_iterator_data(it);
        left = bnf_alternative_set(left, alt);
    }

    /* delete right part */
    free_avl_tree(right->as_set);
    free(right);

    return left;
} /* bnf_merge_alternative_sets */
