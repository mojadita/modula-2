LIB=libstubs.a

for N
do
	cat <<EOF >stub_${N}.c
/* stub_${N}.c --- stub callback to allow to compile unimplemented stuff.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: $(LANG=C date)
 * Copyright: (C) LUIS COLORADO.  All rights reserved.
 * License: BSD
 * NOTE: This file generated automatically.  DON\'T EDIT.
 */
#include <stdio.h>
#include <stdlib.h>

#include "global.h"
#include "tree.h"

int reduce_${N}_cb(union tree_node nod)
{
	if (global.flags & GL_FLAG_SHOW_STUBS) {
		WARN("NOT IMPLEMENTED YET. USING stub FUNCTION FROM "
			"${LIB} FOR reduce_${N}_cb() FUNCTION\\n");
	}
	return 0;
}
/* EOF */
EOF
	echo stub_${N}.c
done
