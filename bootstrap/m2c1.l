%{
/* m2c1.l -- simple filter to eliminate nested comments in MODULA-2.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Copyright: (C) 2018 Luis Colorado.  All rights reserved.
 * License: BSD
 * Date: Tue May  8 14:17:52 EEST 2018
 */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <getopt.h>
#include <errno.h>

#include "global.h"

int lvl = 0; /* nesting level of comment */

%}

%%

"(*"    { lvl++; fputs("  ", stdout); }
"*)"    { if (lvl > 0) { lvl--; fputs("  ", stdout); }}
\n      ECHO;
.       { if (lvl) fputs(" ", stdout); else ECHO; }

%%

int main(int argc, char **argv)
{
    global_config(argc, argv);
    argc -= global.getopt_optind;
    argv += global.getopt_optind;

    if (global.flags & GL_FLAG_VERBOSE_PREPROCESSOR) {
        fprintf(stderr, F("ARGS: "));
        print_argv(stderr, argv, "", " ", "");
    }
    if (argc == 1) {
        yyin = fopen(argv[0], "rt");
        if (!yyin) {
                ERROR("open: %s: %s (errno = %d)\n",
            argv[0], strerror(errno), errno);
        }
    }
    yylex();
}

int yywrap()
{
    return 1;
}
