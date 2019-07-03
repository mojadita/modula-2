/* stub_DefinitionModule.c --- stub callback to allow to compile unimplemented stuff.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Wed Jul  3 09:06:40 EEST 2019
 * Copyright: (C) LUIS COLORADO.  All rights reserved.
 * License: BSD
 * NOTE: This file generated automatically.  DON'T EDIT.
 */
#include <stdio.h>
#include <stdlib.h>

#include "global.h"
#include "tree.h"

int reduce_DefinitionModule_cb(union tree_node nod)
{
	if (global.flags & GL_FLAG_SHOW_STUBS) {
		WARN("NOT IMPLEMENTED YET. USING stub_DefinitionModule.c for %s function\n", __func__);
	}
	return 0;
}
/* EOF */
