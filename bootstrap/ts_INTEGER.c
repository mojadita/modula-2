/* stub_INTEGER.c --- stub callback to allow to compile unimplemented stuff.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Fri Aug 31 23:48:54 EEST 2018
 * Copyright: (C) LUIS COLORADO.  All rights reserved.
 * NOTE: This file generated automatically.  DON'T EDIT.
 */
#include <stdio.h>

#include "tree.h"

char *to_string_INTEGER_cb(union tree_node nod, char *b, size_t sz)
{
	int i = nod.INTEGER->ival;
	snprintf(b, sz, "\033[31mINTEGER(\033[1;33m%d-%oB-%xH\033[0;31m)", i, i, i);
    return b;
}

/* EOF */
