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


struct ConstFactor {
	struct type *type;
	union {
		int			integer;
		unsigned	cardinal;
		double		real;
		char		*string;
    }               u;
};

struct ConstFactor *ConstFactor_from_qualident(struct qualident *qi);
struct ConstFactor *ConstFactor_from_INTEGER(int i);
struct ConstFactor *ConstFactor_from_DOUBLE(double d);
struct ConstFactor *ConstFactor_from_STRING(char *d);
struct ConstFactor *ConstFactor_from_CHARLIT(int d);
struct ConstFactor *ConstFactor_from_set(struct set *s);
struct ConstFactor *ConstFactor_from_ConstExpression(struct ConstExpression *e);
struct ConstFactor *ConstFactor_from_NOT_ConstFactor(struct ConstFactor *f);

#endif /* M2P_H */
