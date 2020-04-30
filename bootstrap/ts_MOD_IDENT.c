/* stub_MOD_IDENT.c --- stub callback to allow to compile unimplemented stuff.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Fri Aug 31 23:48:54 EEST 2018
 * Copyright: (C) LUIS COLORADO.  All rights reserved.
 * License: BSD
 * NOTE: This file generated automatically.  DON'T EDIT.
 */
#include <stdio.h>

#include "tree.h"

#ifndef USE_COLOR
#error please, define USE_COLOR to compile this source.
#endif

#if USE_COLOR
#define COLOR(n) "\033[" n "m"
#define P1 COLOR("31")
#define P2 COLOR("37")
#define P(_p1, _p2, _p3) P1 _p1 P2 _p2 P1 _p3
#else
#define P(_p1, _p2, _p3) _p1 _p2 _p3
#endif

char *to_string_MOD_IDENT_cb(union tree_node nod, char *b, size_t sz)
{
    const char *s = nod.MOD_IDENT->ident_string;

    snprintf(b, sz, P("MOD_IDENT[", "%s", "]"), s);
    return b;
}

/* EOF */
