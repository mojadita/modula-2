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

static size_t print_subtree_NONTERMINAL(union tree_node nod, FILE *f, enum child_type ct);
static size_t print_subtree_TERMINAL(union tree_node nod, FILE *f, enum child_type ct);
static size_t print_node_NONTERMINAL(union tree_node nod, FILE *f);
static size_t print_node_TERMINAL(union tree_node nod, FILE *f);

#define NTS(_name,_prnt)                            \
    {   .to_string = to_string_NONTERMINAL_cb,      \
        .print_subtree = print_subtree_NONTERMINAL, \
        .print_node = print_node_NONTERMINAL,       \
        .tag = CL_##_name,                          \
        .node_type = NT_NONTERMINAL,                \
        .name = #_name,                             \
        .on_reduce = reduce_##_name##_cb,           \
    },
struct static_part_NONTERMINAL nts_static[] = {
#include "nts.i"
}; 
#undef NTS


#define TNT(_name)                                  \
struct static_part_TERMINAL _name##_static = {      \
    .to_string = to_string_##_name##_cb,            \
    .print_subtree = print_subtree_TERMINAL,        \
    .print_node = print_node_TERMINAL,              \
    .tag = NT_##_name,                              \
    .node_type = NT_##_name,                        \
    .name = #_name,                                 \
};
#include "tnt.i"
#undef TNT

static char pfx[1024],
           *pfx_end = pfx;
size_t      pfx_sz = sizeof pfx;

size_t print_subtree(union tree_node nod, FILE *f, enum child_type ct)
{
	return nod.NONTERMINAL->static_part->print_subtree(nod, f, ct);
} /* print_subtree */

size_t print_node(union tree_node nod, FILE *f)
{
    return nod.NONTERMINAL->static_part->print_node(nod, f);
} /* print_node */

char *to_string(union tree_node nod, char *buff, size_t bsz)
{
    return nod.NONTERMINAL->static_part->to_string(
            nod, buff, bsz);
}

#define SAVE(type, var) type var##_saved = var
#define ACT(n) do{pfx_end += n; pfx_sz -= n;}while(0)
#define RESTORE(var) var = var##_saved
static size_t print_subtree_NONTERMINAL(union tree_node nod, FILE *f, enum child_type ct)
{
    int i;
    size_t res = 0;
    char *prefix_this,
         *prefix_children;
    SAVE(char *, pfx_end);
    SAVE(size_t, pfx_sz);

    switch(ct) {
    case ROOT_NODE:
        pfx[0] = 0;
        pfx_end = pfx;
        pfx_sz = sizeof pfx;
        prefix_this = prefix_children = "";
        break;
    case NON_LAST_CHILD:
        prefix_this = "\u251c\u2500"; prefix_children = "\u2502 ";
        break;
    case LAST_CHILD:
        prefix_this = "\u2514\u2500"; prefix_children = "  ";
        break;
    } /* switch */

    /* go with this node and print it */ snprintf(pfx_end, pfx_sz, "%s", prefix_this);
    res += print_node(nod, f);

    /* go with children */
    size_t l = snprintf(pfx_end, pfx_sz, "%s", prefix_children);
    ACT(l);
    size_t n_children = nod.NONTERMINAL->n_children;
    for(i = 0; i < n_children; i++)
        res += print_subtree(nod.NONTERMINAL->child[i], f,
                    i < n_children-1 ? NON_LAST_CHILD : LAST_CHILD );
    RESTORE(pfx_sz);
    RESTORE(pfx_end);
    *pfx_end = 0;
    return res;
}

static size_t print_subtree_TERMINAL(union tree_node nod, FILE *f, enum child_type ct)
{
    char *prefix_this;

    switch(ct) {
    case ROOT_NODE:
        pfx[0] = 0;
        pfx_end = pfx;
        pfx_sz = sizeof pfx;
        prefix_this = "";
        break;
    case NON_LAST_CHILD:
        prefix_this = "\u255e\u2550";
        break;
    case LAST_CHILD:
        prefix_this = "\u2558\u2550";
        break;
    } /* switch */

    snprintf(pfx_end, pfx_sz, "%s", prefix_this);
	return print_node(nod, f);
}

size_t print_node_NONTERMINAL(union tree_node data, FILE *f)
{  
    char buff[128];
    size_t res = 0;
    res += fprintf(f, F("%s\033[37mRule\033[1;33m-%03d\033[0;37m: %s \033[31m::="), 
            pfx,
            data.NONTERMINAL->rule_num,
            to_string(data, buff, sizeof buff));
    int i, n = data.NONTERMINAL->n_children;
    union tree_node *children = data.NONTERMINAL->child;
        if (n) for (i = 0; i < n; i++) {
            union tree_node child = children[i];
            assert(child.NONTERMINAL != NULL);
            res += fprintf(f, " %s", 
                to_string(child, buff, sizeof buff));
        } else {
            res += fprintf(f, " \033[34m/* EMPTY */");
        }
        res += fprintf(f, " \033[31m.\033[m\n");

    return res;
}

size_t print_node_TERMINAL(union tree_node data, FILE *f)
{
    char buff[64];
    return fprintf(f, F("%s\033[37mTerminal\033[1;33m-%03d\033[0;37m: %s\033[m\n"),
            pfx,
            data.IDENT->static_part->node_type,
            to_string(data, buff, sizeof buff));
} /* print_node_TERMINAL */

union tree_node alloc_NONTERMINAL(enum nts_tag tag, int rule, size_t n_children , ...)
{
    union tree_node res;
    res.NONTERMINAL = malloc(sizeof *res.NONTERMINAL);
    res.NONTERMINAL->static_part = nts_static + tag;
    res.NONTERMINAL->rule_num = rule;
    res.NONTERMINAL->n_children = n_children;
    res.NONTERMINAL->child = malloc(n_children * sizeof(union tree_node));
    va_list p;
    va_start(p, n_children);
    int i;
    for(i = 0; i < n_children; i++)
        res.NONTERMINAL->child[i] = va_arg(p, union tree_node);
    va_end(p);
    /* TODO: intern the node */
    if (res.NONTERMINAL->static_part->on_reduce)
        res.NONTERMINAL->static_part->on_reduce(res);
    char buffer[64];
    if (global.flags & GL_FLAG_VERBOSE_PARSER)
    	print_node(res, stdout);
    return res;
} /* alloc_NONTERMINAL */

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
