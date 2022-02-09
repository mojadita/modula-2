/* ts_CHARLIT.c --- stub callback to allow to compile unimplemented stuff.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Fri Aug 31 23:48:53 EEST 2018
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
#endif

#define P1 COLOR("31")
#define P2 COLOR("37")
#define P(_p1, _p2, _p3) P1 _p1 P2 _p2 P1 _p3

static char *fmts[] = {
    P("CHARLIT[", "%oC", "]"),
    P("CHARLIT[", "'%c'", "]"),
};

char *
to_string_CHARLIT_cb(
        union tree_node nod,
        char *b,
        size_t sz)
{
    int c = nod.CHARLIT->ival;
    snprintf(b, sz, fmts[isprint(c) != 0], c);
    return b;
}

/* EOF */
