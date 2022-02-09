/* ts_SYMBOL.c --- stub callback to allow to compile unimplemented stuff.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Fri Aug 31 23:48:54 EEST 2018
 * Copyright: (C) LUIS COLORADO.  All rights reserved.
 * License: BSD
 */
#include <ctype.h>
#include <stdio.h>

#include "tree.h"

#ifndef USE_COLOR
#   warning please, define USE_COLOR to compile this source with color support.
#endif

#if USE_COLOR
#   define COLOR(n) "\033[" n "m"
#else /* USE_COLOR */
#   define COLOR(n)
#endif /* USE_COLOR */

#define P1 COLOR("36")
#define P(_p1) P1 _p1

static char *labls[] = {
    P("'%s'"),
    P("%s"),
};

char *
to_string_SYMBOL_cb(
        union tree_node nod,
        char *b,
        size_t sz)
{
    const char *l = nod.SYMBOL->lexeme;
    snprintf(b, sz, labls[isalpha(l[0]) != 0], l);
    return b;
}

/* EOF */
