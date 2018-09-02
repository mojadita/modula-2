/* tree.c --- implementation of the parse tree.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Wed Aug 29 09:52:06 EEST 2018
 * Copyright: (C) 2018 LUIS COLORADO.  All rights reserved.
 */

#include <assert.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>

#include "global.h"
#include "tree.h"

#define NTS(_name)							\
    {	.to_string = to_string_NONLEAF_cb,	\
    	.tag = CL_##_name,					\
		.name = #_name,						\
	    .on_reduce = reduce_##_name##_cb,	\
	},
struct static_part_nonterminal nts_static[] = {
#include "nts.i"
}; 
#undef NTS

#define TNT(_name)						\
struct static_part_terminal _name##_static = {	\
	.to_string = to_string_##_name##_cb,\
	.tag = NT_##_name,					\
	.name = #_name,						\
};
#include "tnt.i"
#undef TNT

void print_node(union tree_node data)
{
	char buff[63];

	printf(F("Rule-%03d: %s ::="), 
		data.NONLEAF->rule_num,
		data.NONLEAF->static_part->to_string(
			data, buff, sizeof buff));
	int i, n = data.NONLEAF->n_children;
	union tree_node *children = data.NONLEAF->child;
	if (n) for (i = 0; i < n; i++) {
		union tree_node child = children[i];
		if (child.NONLEAF) {
			printf(" %s", 
				child.NONLEAF->static_part->to_string(
					child,
					buff, sizeof buff));
		} else
			printf(" <<<#%d-NULL>>>", i+1);
	} else {
		printf(" /* EMPTY */");
	}
	puts(" .");
}


union tree_node alloc_NONLEAF(enum nts_tag tag, int rule, size_t n_children , ...)
{
    union tree_node res;
    res.NONLEAF = malloc(sizeof *res.NONLEAF);
    res.NONLEAF->static_part = nts_static + tag;
    res.NONLEAF->rule_num = rule;
    res.NONLEAF->n_children = n_children;
    res.NONLEAF->child = malloc(n_children * sizeof(union tree_node));
    va_list p;
    va_start(p, n_children);
	int i;
    for(i = 0; i < n_children; i++)
        res.NONLEAF->child[i] = va_arg(p, union tree_node);
    va_end(p);
    /* TODO: intern the node */
	if (res.NONLEAF->static_part->on_reduce)
        res.NONLEAF->static_part->on_reduce(res);
	char buffer[64];
	print_node(res);
    return res;
} /* alloc_NONLEAF */

union tree_node alloc_IDENT(const char *ident_string)
{
    union tree_node res;
    res.IDENT = malloc(sizeof *res.IDENT);
    res.IDENT->static_part = &IDENT_static;
    res.IDENT->ident_string = ident_string;
    /* TODO: intern the node */
    return res;
} /* alloc_IDENT */

union tree_node alloc_MOD_IDENT(const char *ident_string)
{
    union tree_node res;
    res.MOD_IDENT = malloc(sizeof *res.MOD_IDENT);
    res.MOD_IDENT->static_part = &MOD_IDENT_static;
    res.MOD_IDENT->ident_string = ident_string;
    /* TODO: intern the node */
    return res;
} /* alloc_MOD_IDENT */

union tree_node alloc_INTEGER(int ival)
{
    union tree_node res;
    res.INTEGER = malloc(sizeof *res.INTEGER);
    res.INTEGER->static_part = &INTEGER_static;
    res.INTEGER->ival = ival;
    /* TODO: intern the node */
    return res;
} /* alloc_INTEGER */

union tree_node alloc_CHARLIT(int ival)
{
    union tree_node res;
    res.CHARLIT = malloc(sizeof *res.CHARLIT);
    res.CHARLIT->static_part = &CHARLIT_static;
    res.CHARLIT->ival = ival;
    /* TODO: intern the node */
    return res;
} /* alloc_CHARLIT */

union tree_node alloc_REAL(double dval)
{
    union tree_node res;
    res.REAL = malloc(sizeof *res.REAL);
    res.REAL->static_part = &REAL_static;
    res.REAL->dval = dval;
    /* TODO: intern the node */
    return res;
} /* alloc_REAL */

union tree_node alloc_STRING(const char *sval)
{
    union tree_node res;
    res.STRING = malloc(sizeof *res.STRING);
    res.STRING->static_part = &STRING_static;
    res.STRING->sval = sval;
    /* TODO: intern the node */
    return res;
} /* alloc_STRING */

union tree_node alloc_SYMBOL(int token , const char *lexeme)
{
    union tree_node res;
    res.SYMBOL = malloc(sizeof *res.SYMBOL);
    res.SYMBOL->static_part = &SYMBOL_static;
    res.SYMBOL->token = token;
    res.SYMBOL->lexeme = lexeme;
    /* TODO: intern the node */
    return res;
} /* alloc_SYMBOL */
