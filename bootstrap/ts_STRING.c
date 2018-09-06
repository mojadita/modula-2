/* stub_STRING.c --- stub callback to allow to compile unimplemented stuff.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Fri Aug 31 23:48:54 EEST 2018
 * Copyright: (C) LUIS COLORADO.  All rights reserved.
 * NOTE: This file generated automatically.  DON'T EDIT.
 */
#include <stdio.h>

#include "tree.h"

#define COLOR(n) "\033[" n "m"
#define P1 COLOR("31")
#define P2 COLOR("37")
#define P(_p1, _p2, _p3) P1 _p1 P2 _p2 P1 _p3

char *to_string_STRING_cb(union tree_node nod, char *b, size_t sz)
{
    snprintf(b, sz, P("STRING[", "'%s'", "]"), nod.STRING->sval);
    return b;
}

/* EOF */
