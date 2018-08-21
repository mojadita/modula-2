%{
/* m2c1.l -- simple filter to eliminate nested comments in MODULA-2.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Tue May  8 14:17:52 EEST 2018
 */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <getopt.h>
#include <errno.h>

#define F(fmt) __FILE__ ":%d:%s: " fmt, __LINE__, __func__

int lvl = 0; /* nesting level of comment */

%}

%%

"(*"	{ lvl++; fputs("  ", stdout); }
"*)"	{ if (lvl > 0) { lvl--; fputs("  ", stdout); }}
\n		ECHO;
.		{ if (lvl) fputs(" ", stdout); else ECHO; }

%%

int main(int argc, char **argv)
{
	if ( argc > 2 ) {
		int i;
		fprintf(stderr,
			F("WARNING: ignoring extra params"));
		for (i = 2; i < argc; i++)
			fprintf(stderr, " \"%s\"", argv[i]);
		fputs("\n", stderr);
	}
	if ( argc == 2) {
		yyin = fopen(argv[1], "rt");
		if (!yyin) {
			fprintf(stderr,
				F("ERROR: %s: %s (errno = %d)\n"),
				argv[1], strerror(errno), errno);
			exit(EXIT_FAILURE);
		}
	}
	yylex();
}

int yywrap()
{
	return 1;
}
