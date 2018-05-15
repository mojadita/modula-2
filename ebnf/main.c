/* main.c -- main program for ebnf parser.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Tue May 15 11:19:02 EEST 2018
 */

#include <errno.h>
#include <getopt.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "const.h"

void do_help(void);
int yyparse(void);

extern FILE *yyin;

int main(int argc, char **argv)
{
	int opt;
	while((opt = getopt(argc, argv, "h")) != EOF) {
		switch(opt) {
		case 'h': do_help(); exit(EXIT_SUCCESS);
		} /* switch */
	} /* while */

	argc -= optind; argv += optind;

	if (argc > 1) {
		int i;
		fprintf(stderr, F("WARNING: extra args"));
		for (i = 1; i < argc; i++)
			fprintf(stderr, " \"%s\"", argv[i]);
		fprintf(stderr, " ignored.\n");
	}

	if (argc > 0) {
		char *f = argv[0];
		yyin = fopen(f, "rt");
		if (!yyin) {
			fprintf(stderr, F("ERROR: %s: %s (errno = %d)\n"),
				f, strerror(errno), errno);
			exit(EXIT_FAILURE);
		}
	}

	yyparse();

	exit(EXIT_SUCCESS);
} /* main */

void do_help()
{
	fputs(
		"Usage: ebnf [ options ... ] file\n"
		"where options are:\n"
		"  -h  show this help screen.\n"
		"and file is the file to be parsed.  In case no\n"
		"file is specified, it defaults to standard input.\n",
		stderr);
} /* do_help */
