/* balts.h -- definitions for bnf_alternative_set_t
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Fri Jun 15 00:09:06 EEST 2018
 */
#ifndef BALTS_H
#define BALTS_H

#include "ebnfp.h"

typedef struct bnf_alternative_set {
    size_t                    as_ref_count;
    AVL_TREE                  as_set;
} *bnf_alternative_set_t;

bnf_alternative_set_t bnf_alternative_set(bnf_alternative_set_t head, bnf_alternative_t tail);

bnf_alternative_set_t bnf_merge_alternative_lists(bnf_alternative_set_t left, bnf_alternative_set_t right);

#endif /* BALTS_H */
