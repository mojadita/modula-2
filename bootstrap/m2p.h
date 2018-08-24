/* m2p.h -- definitions for the MODULA-2 parser.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Tue Aug 21 08:32:18 EEST 2018
 */
#ifndef M2P_H
#define M2P_H

#include <sys/types.h>
#include "y.tab.h"

#define F(fmt) __FILE__":%04d:%-8s - " fmt,__LINE__,__func__
#define ERROR(fmt, ...) do {\
			fprintf(stderr, F("ERROR: " fmt), ##__VA_ARGS__);\
			exit(1);\
	} while(0)

extern int yylex(void);

struct res_word {
	const int token_val;
	const char * const lexem;
};

struct module {
	char *name;
};

struct module *mod_lookup(char *name);

extern const struct res_word *rw_lookup(const char *nam);
#endif /* M2P_H */
