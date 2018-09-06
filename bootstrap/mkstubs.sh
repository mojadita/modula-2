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

int reduce_${N}_cb(union tree_node nod)
{
#if 0
	WARN("NOT IMPLEMENTED YET. USING stub_${N}.c for %s function\\n", __func__);
#endif
	return 0;
}
/* EOF */
EOF
	echo stub_${N}.c
done
