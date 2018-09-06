/* stub_NONTERMINAL.c --- stub callback to allow to compile unimplemented stuff.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Fri Aug 31 23:48:54 EEST 2018
 * Copyright: (C) LUIS COLORADO.  All rights reserved.
 * NOTE: This file generated automatically.  DON'T EDIT.
 */
#include <stdio.h>

#include "tree.h"

#define COLOR(n) "\033[" n "m"
#define P1 COLOR("37")
#define P2 COLOR("32")
#define P(_p1, _p2, _p3, _p4, _p5) P1 _p1 P2 _p2 P1 _p3 P2 _p4 P1 _p5

char *to_string_NONTERMINAL_cb(union tree_node nod, char *b, size_t sz)
{
    snprintf(b, sz, P("<", "%s", "-", "%d", ">"),
            nod.NONTERMINAL->static_part->name,
            nod.NONTERMINAL->static_part->tag);
    return b;
}

/* EOF */
