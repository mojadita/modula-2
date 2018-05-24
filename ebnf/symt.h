/* symt.h -- symbol table definitions.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Wed May 16 11:53:10 EEST 2018
 */
#ifndef SYMT_H
#define SYMT_H

#include <avl.h>

AVL_TREE symt_symbols;
AVL_TREE symt_strings;

#define SYMT_TYPE_BITS          (4)
#define SYMT_TYPE_MASK          ((1 << SYMT_TYPE_BITS) - 1)

#define SYMT_TYPE_UNDEF         (0) /* not defined yet */
#define SYMT_TYPE_IDENT         (1) /* symbol is an identifier */
#define SYMT_TYPE_SYMBOL        (2) /* symbol is an operator */
#define SYMT_TYPE_STRING        (3) /* symbol is a string */

#define SYMT_NONTERM            (1 << (SYMT_TYPE_BITS + 0))

typedef struct symt_entry {
	unsigned long long	 e_id;
	char		        *e_lit;
	unsigned             e_flags;
	bnf_rule_t           e_rule;
} *symt_entry_t;

symt_entry_t symt_lookup(AVL_TREE tab, const char *key);
symt_entry_t symt_lookup_symbol(const char *name);
symt_entry_t symt_lookup_string(const char *name);

#endif /* SYMT_H */
