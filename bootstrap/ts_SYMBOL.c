/* stub_SYMBOL.c --- stub callback to allow to compile unimplemented stuff.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Fri Aug 31 23:48:54 EEST 2018
 * Copyright: (C) LUIS COLORADO.  All rights reserved.
 * License: BSD
 * NOTE: This file generated automatically.  DON'T EDIT.
 */
#include <ctype.h>
#include <stdio.h>

#include "tree.h"

#ifndef USE_COLOR
#error please, define USE_COLOR to compile this source.
#endif

#if USE_COLOR
#define COLOR(n) "\033[" n "m"
#define P1 COLOR("36")
#define P(_p1) P1 _p1
#else
#define P(_p1) _p1
#endif

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
