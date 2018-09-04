/* stub_IDENT.c --- stub callback to allow to compile unimplemented stuff.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Fri Aug 31 23:48:53 EEST 2018
 * Copyright: (C) LUIS COLORADO.  All rights reserved.
 * NOTE: This file generated automatically.  DON'T EDIT.
 */
#include <stdio.h>

#include "tree.h"

char *to_string_IDENT_cb(union tree_node nod, char *b, size_t sz)
{
	snprintf(b, sz, "\033[34mIDENT(\033[1;33m%s\033[0;34m)", nod.IDENT->ident_string);
    return b;
}

/* EOF */
