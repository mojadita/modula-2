/* tree.c -- parse tree construction primitives.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Tue May 15 09:39:12 EEST 2018
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <avl.h>

#include "const.h"

#ifndef DEBUG
#define DEBUG (0)
#endif

#define PR2(a,b) do{							\
		if (main_flags & FLAG_TRACE_SYNTREE)	\
			printf(F(#a ": %p, " #b				\
					": %p ==> %p;\n"),			\
				a, b, res);						\
	} while(0)

#define PR1(a) do{								\
		if (main_flags & FLAG_TRACE_SYNTREE)	\
			printf(F(#a ": %p ==> %p;\n"),		\
				a, res);						\
	} while(0)

#include "ebnfp.h"
