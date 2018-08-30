/* tree.h --- definitions for pseudo oop parse tree module.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Wed Aug 29 07:38:15 EEST 2018 
 * Copyright: (C) 2018 LUIS COLORADO.  All rights reserved.
 */
#ifndef TREE_H
#define TREE_H

#include <stdarg.h>

#define ROOT_FIELDS						\
	struct static_part	*static_part;

/* for grammatical cathegories (nonleaf nodes)
 * This includes nonterminal symbols. */
#define NONLEAF_FIELDS					\
	ROOT_FIELDS							\
	size_t				n_children;		\
	int					rule_num;		\
	union	tree_node	**child;

/* the following are the terminal symbols
 * of the language.  They are classified as:
 * IDENT, MOD_IDENT (identifiers with specific lexeme
 * 		to be used as identifiers in source program)
 * INTEGER.  These are converted to internal format
 *		to intern them, as there are differnt ways to
 *		write them, so all references point to the
 *		same canonical value.
 * REAL.  Same as INTEGER.
 * STRING.  Strings can be written as double quoted
 *		literals and single quoted literals. Interning
 *		works independent of the quoting method used to
 *		write the string.
 * SYMBOL.  These tokens represent the keywords of the
 *		language and the one/several char symbols.  Symbol
 *		aliasing (as '<>' == '#' and '&' == AND) IS NOT
 *		RESOLVED HERE, but treated in the syntax parser.
 */
#define IDENT_FIELDS					\
	ROOT_FIELDS							\
	char			   *ident_string;

#define MOD_IDENT_FIELDS IDENT_FIELDS

#define INTEGER_FIELDS					\
	ROOT_FIELDS							\
	int					ival;

#define CHARLIT_FIELDS					\
	INTEGER_FIELDS						\
	char				*lexeme;

#define REAL_FIELDS					\
	ROOT_FIELDS							\
	double				dval;

#define STRING_FIELDS					\
	ROOT_FIELDS							\
	char				*sval;

#define SYMBOL_FIELDS					\
	ROOT_FIELDS							\
	int					token;			\
	char			   *lexeme;

/* this macro creates COMPLETE types for each of the
 * different structures, and a union, to group them all.
 */
#define ST(n)							\
	struct n {							\
		n##_FIELDS						\
	};
#include "nodetypes.i"
#undef ST
#define ST(n)	struct n *n;
union tree_node {
#include "nodetypes.i"
}; /* union tree_node */
#undef ST
#define ST(n) NT_##n,
enum node_type {
#include "nodetypes.i"
};
#define SP_FLAG_TERMINAL			(1 << 0)
#undef ST
struct static_part {
	int					flgs;
	int					tag;
	char			   *name;
};
#define NT(name) CL_##name,
enum nln_tag {
#include "tree.i"
}; /* enum tree_tag */
#undef NT
#undef ST

union tree_node alloc_NONLEAF(enum nln_tag tag, int rule, size_t n_children , ...);
union tree_node alloc_IDENT(const char *ident_string);
union tree_node alloc_MOD_IDENT(const char *ident_string);
union tree_node alloc_INTEGER(int ival);
union tree_node alloc_REAL(double dval);
union tree_node alloc_STRING(const char *sval);
union tree_node alloc_CHARLIT(int ival, const char *lexeme);
union tree_node alloc_SYMBOL(int token , const char *lexeme);

#endif /* TREE_H */
