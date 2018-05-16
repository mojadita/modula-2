/* const.h -- constants and general definitions.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Tue May 15 10:18:37 EEST 2018
 */
#ifndef CONST_H
#define CONST_H

#define F(_f) __FILE__":%d:%s: " _f, __LINE__, __func__
#define I(_n, _f) "%*s" _fmt, (_n), ""

#define FLAG_TRACE_SCAN		(1 << 0)
#define FLAG_TRACE_PARSE	(1 << 1)
#define FLAG_TRACE_SYNTREE	(1 << 2)
extern int main_flags;

#endif /* CONST_H */
