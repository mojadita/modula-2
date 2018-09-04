/* stub_NONTERMINAL.c --- stub callback to allow to compile unimplemented stuff.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Fri Aug 31 23:48:54 EEST 2018
 * Copyright: (C) LUIS COLORADO.  All rights reserved.
 * NOTE: This file generated automatically.  DON'T EDIT.
 */
#include <stdio.h>

#include "tree.h"

char *to_string_NONTERMINAL_cb(union tree_node nod, char *b, size_t sz)
{
    snprintf(b, sz, "\033[37m<\033[32m%s\033[1;33m-%d\033[0;37m>",
            nod.NONTERMINAL->static_part->name,
            nod.NONTERMINAL->static_part->tag);
    return b;
}

/* EOF */
