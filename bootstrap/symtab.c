/* symtab.c --- implementation of symbol table module.
 * Date: Mon Aug 27 21:32:58 EEST 2018
 * Copyright: (C) 2018 Luis Colorado.  All rights reserved.
 * License: BSD
 */
#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include "symtab.h"

struct symtab *
new_symtab(struct symtab *prnt)
{
    struct symtab *result = malloc(sizeof *result);
    assert(result != NULL);
    result->parent = prnt;
    result->local_symbols = new_avl_tree(
            (AVL_FCOMP) strcmp,
            (AVL_FCONS) NULL,
            (AVL_FDEST) NULL,
            (AVL_FPRNT) NULL);
    result->display_level = prnt ? prnt->display_level + 1 : 0;
    return result;
} /* new_symtab */

void
free_symtab(struct symtab *tab)
{
    free_avl_tree(tab->local_symbols);
    free(tab);
} /* sym_lookup */

void *
sym_lookup(struct symtab *tab, char *key)
{
    void *result = NULL;
    for (;tab; tab = tab->parent)
        if ((result = avl_tree_get(tab->local_symbols, key)) != NULL)
            return result;
    return result;
} /* sym_lookup */

void *
sym_add(struct symtab *tab, char *key, void *ctt)
{
    void *p = avl_tree_get(tab->local_symbols, key);
    if (p) return p;
    avl_tree_put(tab->local_symbols, key, ctt);
    return 0;
} /* sym_add */
