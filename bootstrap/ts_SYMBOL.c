/* stub_SYMBOL.c --- stub callback to allow to compile unimplemented stuff.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Fri Aug 31 23:48:54 EEST 2018
 * Copyright: (C) LUIS COLORADO.  All rights reserved.
 * NOTE: This file generated automatically.  DON'T EDIT.
 */
#include <ctype.h>
#include <stdio.h>

#include "tree.h"

char *to_string_SYMBOL_cb(union tree_node nod, char *b, size_t sz)
{
    if (isalpha(nod.SYMBOL->lexeme[0]))
        snprintf(b, sz, "%s", nod.SYMBOL->lexeme); /* RESERVED WORD */
    else
        snprintf(b, sz, "SYMBOL('%s'-%d)", nod.SYMBOL->lexeme, nod.SYMBOL->token);
    return b;
}

/* EOF */
