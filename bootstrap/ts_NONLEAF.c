/* stub_NONLEAF.c --- stub callback to allow to compile unimplemented stuff.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Fri Aug 31 23:48:54 EEST 2018
 * Copyright: (C) LUIS COLORADO.  All rights reserved.
 * NOTE: This file generated automatically.  DON'T EDIT.
 */
#include <stdio.h>

#include "tree.h"

char *to_string_NONLEAF_cb(union tree_node nod, char *b, size_t sz)
{
    snprintf(b, sz, "<%s-%d>",
            nod.NONLEAF->static_part->name,
            nod.NONLEAF->static_part->tag);
    return b;
}

/* EOF */
