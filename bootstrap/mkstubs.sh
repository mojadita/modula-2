for N
do
	cat <<EOF >stub_${N}.c
/* stub_${N}.c --- stub callback to allow to compile unimplemented stuff.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: $(LANG=C date)
 * Copyright: (C) LUIS COLORADO.  All rights reserved.
 * NOTE: This file generated automatically.  DON'T EDIT.
 */
#include <stdio.h>
#include <stdlib.h>

#include "global.h"
#include "tree.h"

#define NI() do{ \\
		WARN("NOT IMPLEMENTED YET. USING stub_${N}.c for %s function\\n", __func__);\\
		return 0;\\
	}while(0)

int reduce_${N}_cb(union tree_node nod)
{
	NI();
}

#if 0
char *to_string_${N}_cb(union tree_node nod, char *b, size_t sz)
{
	NI();
	return "UNIMPLEMENTED";
}
#endif

/* EOF */
EOF
	echo stub_${N}.c
done
