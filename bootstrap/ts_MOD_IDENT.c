/* stub_MOD_IDENT.c --- stub callback to allow to compile unimplemented stuff.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Fri Aug 31 23:48:54 EEST 2018
 * Copyright: (C) LUIS COLORADO.  All rights reserved.
 * NOTE: This file generated automatically.  DON'T EDIT.
 */
#include <stdio.h>

#include "tree.h"

char *to_string_MOD_IDENT_cb(union tree_node nod, char *b, size_t sz)
{
	const char *s = nod.MOD_IDENT->ident_string;

    snprintf(b, sz, "\033[34mMOD_IDENT(\033[1;33m%s\033[0;34m)", s);
    return b;
}

/* EOF */
