/* tree.c --- implementation of the parse tree.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Wed Aug 29 09:52:06 EEST 2018
 * Copyright: (C) 2018 LUIS COLORADO.  All rights reserved.
 */

#include <assert.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>

#include "tree.h"
#define F(f) __FILE__ "%d:%s: " f, __LINE__, __func__

#define NT(_name) \
	{ .flgs = 0, .tag = CL_##_name, .name = #_name, },
struct static_part nt_static[] = {
#include "tree.i"
}; 
#undef NT

#define ST(_name)						\
struct static_part _name##_static = {	\
	.flgs = SP_FLAG_TERMINAL,			\
	.tag = NT_##_name,					\
	.name = #_name,						\
};
#include "nodetypes.i"
#undef ST

#define NI do{                                             \
        printf(F("%s NOT IMPLEMENTED YET.\n"), __func__); \
        union tree_node result = { .ROOT = NULL, };       \
        return result;                                    \
    }while(0)

union tree_node alloc_NONLEAF(enum nln_tag tag, int rule, size_t n_children , ...)
{
	NI;
}
union tree_node alloc_IDENT(const char *ident_string)
{
	NI;
}
union tree_node alloc_MOD_IDENT(const char *ident_string)
{
	NI;
}
union tree_node alloc_INTEGER(int ival)
{
	NI;
}
union tree_node alloc_REAL(double dval)
{
	NI;
}
union tree_node alloc_STRING(const char *sval)
{
	NI;
}
union tree_node alloc_CHARLIT(int ival, const char *lexeme)
{
	NI;
}
union tree_node alloc_SYMBOL(int token , const char *lexeme)
{
	NI;
}
