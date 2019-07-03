/* m2c.c --- Modula-2 compiler base program.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Sun Sep  2 11:50:27 EEST 2018
 * Copyright: (C) 2018 LUIS COLORADO.  All rights reserved.
 * License: BSD
 */

#include <assert.h>
#include <errno.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

#include "global.h"

char input_file[PATH_MAX];

char *m2c1_args[] = { "m2c1", input_file, NULL, };
char *m2c2_args[] = { "m2c2", "-vtsS", "gps", NULL, };

char **progs[] = {
    m2c1_args, m2c2_args,
};
const size_t n_progs = sizeof progs / sizeof progs[0];

#define E(name) ERROR(name ": %s(errno = %d)\n", strerror(errno), errno)

pid_t new_process(int data_to, int *data_from, char **argv);

int main(int argc, char **argv)
{
    if (global_config(argc, argv)) {
    ERROR("error processing global options, giving up.");
    } /* if */

    if (global.flags & GL_FLAG_VERBOSE_GLOBAL) {
        fprintf(stderr, F("ARGS(%d): "), argc);
    print_argv(stderr, argv, "", " ", "\n");
    }

    int i;

    for (i = global.getopt_optind; i < argc; i++) { /* for each file */
        int chn0 = 0; /* input of program X / output of previous */
        snprintf(input_file, sizeof input_file, "%s", argv[i]);
        new_process(0, &chn0, m2c1_args);
        new_process(chn0, NULL, m2c2_args); close(chn0);
        wait(NULL); wait(NULL); wait(NULL);
    } /* for */
} /* main */

pid_t new_process(int data_to, int *data_from, char **argv)
{
    int fds[2];

    if (data_from) {
        if (pipe(fds) < 0)
            E("pipe");
    }

    pid_t chld_pid = fork();

    if (chld_pid < 0)
        E("fork");
    else if (chld_pid == 0) { /* child process */
        if (data_to) { /* standard input redirected from data_to */
            dup2(data_to, 0);
            close(data_to);
        }
        if (data_from) { /* stdout redirected from fds[0] */
            dup2(fds[1], 1);
            close(fds[1]);
            close(fds[0]);
        }
        if (global.flags & GL_FLAG_VERBOSE_GLOBAL) {
            fprintf(stderr,
                F("EXEC: input=%d; output=%d: "),
                data_to,
                data_from ? fds[0] : 1);
            print_argv(stderr, argv, "", " ", "\n");
        }
        if (global.flags & GL_FLAG_DRY_RUN) {
            exit(EXIT_SUCCESS);
        }
        execvp(argv[0], argv);
        ERROR("exec: %s(errno = %d)\n", strerror(errno), errno);
    }
    if (data_from) {
        close(fds[1]);
        *data_from = fds[0];
    }
    return chld_pid;
} /* new_process */
