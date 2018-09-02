/* stub_CHARLIT.c --- stub callback to allow to compile unimplemented stuff.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Fri Aug 31 23:48:53 EEST 2018
 * Copyright: (C) LUIS COLORADO.  All rights reserved.
 * NOTE: This file generated automatically.  DON'T EDIT.
 */
#include <ctype.h>
#include <stdio.h>

#include "tree.h"

char *to_string_CHARLIT_cb(union tree_node nod, char *b, size_t sz)
{
	int c = nod.CHARLIT->ival;
	if (isprint(c))
		snprintf(b, sz, "CHARLIT(%oC-'%c')", c, c);
	else
		snprintf(b, sz, "CHARLIT(%oC-'%c')", c, c);
    return b;
}

/* EOF */
