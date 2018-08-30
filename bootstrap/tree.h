/* tree.h --- definitions for pseudo oop parse tree module.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Wed Aug 29 07:38:15 EEST 2018 
 * Copyright: (C) 2018 LUIS COLORADO.  All rights reserved.
 */
#ifndef TREE_H
#define TREE_H

#include <stdarg.h>

/* ROOT class fields.  It only includes the pointer to
 * static_part struct defining the static data for
 * instances of this class (and subclasses). */
#define ROOT_FIELDS						\
	struct static_part	*static_part;

/* for grammatical cathegories (nonleaf nodes)
 * This includes nonterminal symbols.
 * All the nonterminal nodes belong to a different
 * class, based on the left side symbol of the
 * grammatical rule.  They are so engaged, so the
 * static_part for these nodes point to the proper
 * class. It derives from the ROOT class (noted
 * here and below, by the inclussion in the first
 * part of all the instance fields of the above
 * struct */
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

/* same as above. */
#define MOD_IDENT_FIELDS IDENT_FIELDS

#define INTEGER_FIELDS					\
	ROOT_FIELDS							\
	int					ival;

#define CHARLIT_FIELDS					\
	INTEGER_FIELDS						\
	char				*lexeme;

#define REAL_FIELDS						\
	ROOT_FIELDS							\
	double				dval;

#define STRING_FIELDS					\
	ROOT_FIELDS							\
	char				*sval;

#define SYMBOL_FIELDS					\
	ROOT_FIELDS							\
	int					token;			\
	char			   *lexeme;

/* next macro (for (T)ree (N)ode (T)ype) creates COMPLETE types for each of the
 * different structures, and a union, to group them all.
 */
#define TNT(n)							\
	struct n {							\
		n##_FIELDS						\
	};
#include "tnt.i"
#undef TNT
#define TNT(n)	struct n *n;
union tree_node {
#include "tnt.i"
}; /* union tree_node */
#undef TNT
#define TNT(n) NT_##n,
enum node_type {
#include "tnt.i"
};
#undef TNT

#define SP_FLAG_TERMINAL			(1 << 0)

struct static_part {
	int					flgs;
	int					tag;
	char			   *name;
};
/* next macro (for (N)on(T)erminal (S)ymbol) creates an enum nts_tag type
 * with constants to be used for tags and for array indexing. */
#undef NTS
#define NTS(name) CL_##name,
enum nts_tag {
#include "nts.i"
}; /* enum nts_tag */
#undef NTS

union tree_node alloc_NONLEAF(enum nts_tag tag, int rule, size_t n_children , ...);
union tree_node alloc_IDENT(const char *ident_string);
union tree_node alloc_MOD_IDENT(const char *ident_string);
union tree_node alloc_INTEGER(int ival);
union tree_node alloc_REAL(double dval);
union tree_node alloc_STRING(const char *sval);
union tree_node alloc_CHARLIT(int ival, const char *lexeme);
union tree_node alloc_SYMBOL(int token , const char *lexeme);

#endif /* TREE_H */
