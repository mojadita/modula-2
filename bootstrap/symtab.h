/* symtab.h --- symbol table definitions.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Mon Aug 27 21:22:15 EEST 2018
 * Copyright: (C) 2018 Luis Colorado.  All rights reserved.
 */
#ifndef _SYMTAB_H
#define _SYMTAB_H
#include <avl.h>

/**
 * Generic structure to store a symbol table.
 * As symbol tables belong to different kinds of objects,
 * they are defined in a type independent way.
 * Symbol tables reference the parent symbol table until
 * no parent is found.  This way a symbol can be searched
 * automatically in all symbol tables and on scope exit,
 * just ignore them, from the tree of definition scopes.
 */
struct symtab {
	struct symtab          *parent;
    int                     display_level;
	AVL_TREE                local_symbols;
};

/**
 * constructor for object type.
 * @param prnt is the parent symbol table of this instance.
 * @return a reference to the new symbol table.
 */
struct symtab *
new_symtab(struct symtab *prnt);

/**
 * destructor for symbol table.
 * properly destroys the avl tree and then
 * frees the memory allocated to symbol table.
 * @param table is the instance to free.
 */
void
free_symtab(struct symtab *table);

/**
 * searches the table for symbol key.
 * @param tab is the symbol table to search.
 * @param key is the name for the symbol to search.
 * @return the reference pointed to by symbol "key".
 */
void *
sym_lookup(struct symtab *tab, char *key);

/**
 * adds a symbol to the table if not already existent
 * on it.  To allow symbol hidding, the table only searches
 * for symbol in local table, not propagating the search
 * to upper levels.
 */
void *sym_add(struct symtab *tab, char *key, void *ctt);

#endif /* _SYMTAB_H */
