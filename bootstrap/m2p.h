/* m2p.h -- definitions for the MODULA-2 parser.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Tue Aug 21 08:32:18 EEST 2018
 */
#ifndef M2P_H
#define M2P_H

#include <sys/types.h>
#include "y.tab.h"

#define F(fmt) __FILE__":%d:%s: " fmt,__LINE__,__func__

extern int yylex(void);

struct res_word {
	const int token_val;
	const char * const lexem;
};

extern const struct res_word *rw_lookup(const char *nam);
#endif /* M2P_H */
