/* split --- splits a string in parts separated by char 'del'.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Tue Sep  4 08:08:52 EEST 2018
 * Copyright: (C) 2018 LUIS COLORADO.  All rights reserved.
 * License: BSD
 */

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define F(fmt) __FILE__":%d:%s: " fmt, __LINE__, __func__

#ifndef DEBUG
#define DEBUG 0
#endif

/* The idea is to target this scenario:
 * |<---------------- cap ptrs --------------->|<-------- bsz chars -------------->|
 * |<------ n pointers ----->|             |                   |
 * +----+----+----+...+------+----+...+--------+--+----+--+----+--+----+...+--+----+
 * |r[0]|r[1]|r[2]|...|r[n-1]|NULL|...|r[cap-1]|s0|'\0'|s1|'\0'|s2|'\0'|...|sn|'\0'|
 * +--+-+--+-+--+-+...+--+---+----+...+--------+--+----+--+----+--+----+...+--+----+
 *    |    |    |        |                        A       A       A           A
 *    `---)|(--)|(-...--)|(--------...------------'       |       |           |
 *         |    |        |                                |       |           |
 *         `---)|(-...--)|(--------...--------------------'       |           |
 *              |        |                                        |           |
 *              `--...--)|(--------...----------------------------'           |
 *                       |                                                    |
 *                       `---------...------------------------------------...-'
 *
 * To achieve, we first create an initial buffer with initial cap and grow it in
 * case we need more space.
 * NOTE: WE ONLY GROW, NEVER DECREASE LENGTH. */
static char **grow(
        char **old_buf, /* reference to old buffer */
        size_t n, size_t old_cap, size_t new_cap, size_t bsz, /* algorithm parameters */
        char **p0, char **p1);

char **split(char *s, char del)
{
    size_t cap0 = 5, cap1 = 8; /* initial capacity, Fibonacci growing */
    size_t bsz = strlen(s) + 1; /* size of buffer with string components */
    size_t n = 0; /* actual number of strings */

    /* construct the initial buffer with capacity cap0 */
    char **res = malloc((sizeof *res) * cap0 /* memory for the pointers */
                        + bsz); /* memory for the string buffer */
    assert(res != NULL);
    char *p = (char *)(res + cap0);  /* initial position of the string buffer */
    strcpy(p, s); /* copy the string buffer */

    /* initialize pointers, s initialises to the position of p, and
     * p moves forward until it reaches the next delimiter char.  On the
     * next pass, s moves to the position o p, and p moves forward. */
    for(s = p; (p = strchr(p, del)) != NULL; s = p) {
        if (n == cap0) {
            /* grow needs to update pointers s & p, as they are
             * used just following this if statement */
            res = grow(res, n, cap0, cap1, bsz, &s, &p);
            int cap2 = cap0 + cap1;
            cap0 = cap1;
            cap1 = cap2;
        }
        res[n++] = s;
        *p++ = 0;
    }
    /* now we need an additional pass to get the last string and the
     * NULL pointer. */
    if (n+2 > cap0) { /* two extra places for last field and NULL pointer */
        /* we only grow that last two places in this case.
         * we don't need to pass p's reference, as we are not longer using it.
         * (indeed, it was NULL, from above) */
        res = grow(res, n, cap0, n+2, bsz, &s, NULL);
    } /* split */
    res[n++] = s; /* add last val */
    res[n] = NULL; /* ... and the NULL pointer */
    return res;
} /* split */

static char **grow(
        char **old_buf, /* reference to old buffer */
        size_t n, size_t old_cap, size_t new_cap, size_t bsz, /* algorithm parameters */
        char **p0, char **p1)
{
    assert(old_buf != NULL); assert(n <= old_cap); assert(old_cap < new_cap); assert(bsz > 1);

    /* we don't use realloc, as the buffer string has to be moved to the end of
     * of the buffer and all the pointers need adjustment to point to the new
     * string locations. */
    char **new_buf = malloc((sizeof *new_buf) * new_cap + bsz); /* new size */
    assert(new_buf != NULL);

    /* copy the string part to the new position */
    memcpy( new_buf + new_cap,
            old_buf + old_cap,
            bsz); /* move the buffer of strings */

    /* change the pointers to point to the new location */
    size_t delta = (char*)(new_buf + new_cap)
                 - (char*)(old_buf + old_cap),
           i;
    for(i = 0; i < n; i++)
        new_buf[i] = old_buf[i] + delta;
    free(old_buf); /* now we can free old buffer safely */

    /* adjust the external pointers */
        *p0 += delta;
    if (p1) *p1 += delta;

    return new_buf;
} /* grow */

#if DEBUG
#include <ctype.h>
#include <getopt.h>
int main(int argc, char **argv)
{
    char buffer[1024];
    int n = 0;
    char del = ':';
    int opt;

    while((opt = getopt(argc, argv, "d:")) >= 0) {
        switch(opt) {
        case 'd': del = optarg[0]; break;
        }
    } /* while */

    while(fgets(buffer, sizeof buffer, stdin)) {
        char *p = strchr(buffer, '\n');
        if (p) *p = '\0';
        for (p = buffer; isspace(*p); p++) {
            continue; /* skip spaces */
        }
        if (*p == '#')
            continue; /* skip comment lines */

        printf("REG #%d: \"%s\"\n", ++n, buffer);
        char **s = split(buffer, del);
        int i;
        for (i = 0; s[i]; i++) {
            printf("  FIELD #%d: \"%s\"\n", i, s[i]);
        }
        free(s);
    }
    return EXIT_SUCCESS;
}
#endif
