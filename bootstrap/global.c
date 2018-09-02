/* global.c --- config variables for the compiler.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Sun Sep  2 04:00:51 EEST 2018
 * Copyright: (C) 2018 LUIS COLORADO.  All rights reserved.
 */

#include <getopt.h>
#include <string.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>

#include "global.h"

struct global global = {
	.flags = 0,
};

static void do_help(int argc, char **argv);

int global_config(int argc, char **argv)
{
	global.prog_name = argv[0];
	int opt, res = 0;
	while ((opt = getopt(argc, argv, "v:hn")) >= 0) {
		switch (opt) {
		case 'v': {
			  int i, l = strlen(optarg);
			  for (i = 0; i < l; i++) {
				  switch(optarg[i]) {
				  case 'g': global.flags |=  GL_FLAG_VERBOSE_GLOBAL; break;
				  case 'p': global.flags |=  GL_FLAG_VERBOSE_PARSER; break;
				  case 's': global.flags |=  GL_FLAG_VERBOSE_SCANNER; break;
				  } /* switch */
			  } /* for */
			  break;}
        case 'h': do_help(argc, argv); exit(EXIT_SUCCESS);
		case 'n': global.flags |= GL_FLAG_DRY_RUN; break;
        case '?': res = -1; break;  /* incorrect option */
        } /* switch */
    } /* while */

    global.getopt_optind = optind;

    return res;
} /* global_config */

size_t print_argv(FILE *f, char **argv, char *s_0, char *s_i, char *s_f)
{
    size_t res = 0, i;

	res += fprintf(f, "%s", s_0);
    for (i = 0; argv[i]; i++) {
		if (i) fputs(s_i, stderr);
        res += fprintf(f, "%s", argv[i]);
	}
	res += fprintf(f, "%s", s_f);

    return res;
} /* print_argv */

#define P(...) fprintf(stderr, ##__VA_ARGS__)
static void do_help(int argc, char **argv)
{
	int i;
	P(F("HELP:"));
	for (i = 0; i < argc; i++)
		P(" %s", argv[i]);
	P("\n");
	P("Usage: m2c [ options ... ]n");
	P("Options:n");
	P("  -h  This help screen is printed to stderrn");
	P("  -v  Be verbose.  This option has a group of letter as subparameter:n");
	P("	  g  Activate global verbosity.n");
	P("	  p  Activate parser verbosity.  This prints rules as they are matchedn");
	P("		 by the parser.n");
	P("	  s  Activate scanner verbosity.  This prints language tokens as theyn");
	P("		 are scanned from the source file.n");
	P("	  G  Deactivate global verbosity.  This allows to deactivate in case itn");
	P("		 has been activated by a previous option.n");
	P("	  P  Deactivate parser verbosity.n");
	P("	  S  Deactivate scanner verbosity.n");
} /* do_help */
#undef P
