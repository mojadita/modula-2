# mkstubs.sh -- shell script to build a library of stubs to be
# called for non implemented routines on rule reduction.
# All these routines are included in a library that is linked at
# the end, to cover all the routines not implemented yet, and
# making the testing possible.
# Author: Luis Colorado <luiscoloradourcola@gmail.com>
# Date: Thu Apr 30 16:10:55 EEST 2020
# Copyright: (c) 2018-2020 LUIS COLORADO.  All rights reserved.
# License: BSD.

LIB=libstubs.a

for N
do
	cat <<EOF >stub_${N}.c
/* stub_${N}.c --- stub callback to allow to compile unimplemented stuff.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: $(LANG=C date)
 * Copyright: (C) 2018-$(date +%Y) LUIS COLORADO.  All rights reserved.
 * License: BSD
 * NOTE: This file generated automatically.  DON\'T EDIT.
 */
#include <stdio.h>
#include <stdlib.h>

#include "global.h"
#include "tree.h"

int reduce_${N}_cb(union tree_node nod)
{
	static int already_issued = 0;
	if (already_issued)
		return 0;
	if (global.flags & GL_FLAG_SHOW_STUBS) {
		WARN("NOT IMPLEMENTED YET. USING "
			"${LIB}(reduce_${N}_cb()) FUNCTION\\n");
		already_issued = 1;
	}
	return 0;
}
/* EOF */
EOF
	echo stub_${N}.c
done
