# Makefile -- makefile for the bootstrap compiler.
# Author: Luis Colorado <luiscoloradourcola@gmail.com>
# Date: Wed May  9 08:50:53 EEST 2018

CFLAGS += -I ../avl_c

targets = m2c1 m2c2

m2c1_objs = m2c1.o

m2c2_objs = m2l.o
m2c2_deps = 
m2c2_ldflags = -L ../avl_c
m2c2_libs = -lavl -lfl

m2p.o: m2p.h m2p.i

.include "../default.mk"
