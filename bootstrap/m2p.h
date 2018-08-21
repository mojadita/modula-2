/* m2p.h -- definitions for the MODULA-2 parser.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Tue Aug 21 08:32:18 EEST 2018
 */
#ifndef M2P_H
#define M2P_H
#include <sys/types.h>
#include "y.tab.h"

struct res_word {
	int token_val;
	char *lexem;
};

extern const struct res_word res_word_tab[];
extern const size_t res_word_tabsz;

#endif /* M2P_H */
