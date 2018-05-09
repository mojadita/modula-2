%{
/* ebnfl.l -- lexical scanner for the ebnf interpreter.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Wed May  9 10:48:26 EEST 2018
 */

#include <stdio.h>
#include <string.h>
#include <errno.h>

#define F(fmt) __FILE__":%d:%s: " fmt, __LINE__, __func__

#define RETURN(tok) printf(F("TOKEN: " #tok "(%s)\n"), yytext)

void do_help();

%}

ident		[a-zA-Z_$][a-zA-Z0-9_]*
s1			"'"([^'\n]|'')*"'"
s2			"\""([^\"\n]|\"\")*"\""
string		({s1}|{s2})

%%

{string}	RETURN(STRING);
{ident}		RETURN(IDENT);
" "			|
\t			|
\r?\n		;
.			RETURN(SYMBOL);

%%

int yywrap()
{
	return 1;
}

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

	yylex();
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
