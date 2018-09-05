/* global.h --- struct global for configuration parameters.
 * Author: Luis Colorado <luiscoloradourcola@gmail.com>
 * Date: Sun Sep  2 03:57:34 EEST 2018
 * Copyright: (C) 2018 LUIS COLORADO.  All rights reserved.
 */
#ifndef GLOBAL_H
#define GLOBAL_H

#define F(fmt) "%s:"__FILE__":%04d:%-8.8s - " fmt,global.prog_name,__LINE__,__func__
#define ERROR(fmt, ...) do {						\
			fprintf(stderr, F("ERROR: " fmt),		\
					##__VA_ARGS__);					\
			exit(EXIT_FAILURE);						\
	} while(0)

#define WARN(fmt, ...) do {							\
			fprintf(stderr, F("WARN: " fmt),		\
					##__VA_ARGS__);					\
	} while(0)

#define GL_FLAG_VERBOSE_GLOBAL 		 	(1 << 0)
#define GL_FLAG_VERBOSE_SCANNER			(1 << 1)
#define GL_FLAG_VERBOSE_PARSER 			(1 << 2)
#define GL_FLAG_VERBOSE_PREPROCESSOR 	(1 << 3)
#define GL_FLAG_DRY_RUN					(1 << 4)

struct global {
    int argc;
    char **argv;
	char *prog_name;
    int getopt_optind;
	int flags;
};

extern struct global global;

int global_config(int argc, char **argv);

size_t print_argv(FILE *f, char **argv, char *s0, char *interm, char *s1);

#endif /* GLOBAL_H */
