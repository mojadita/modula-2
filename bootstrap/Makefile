# Makefile -- makefile for the bootstrap compiler.
# Author: Luis Colorado <luiscoloradourcola@gmail.com>
# Date: Wed May  9 08:50:53 EEST 2018

RM ?= rm -f

targets = m2c1 m2c2

m2c1_objs = m2c1.o

m2c2_objs = m2l.o
m2c2_libs = -lfl

all: $(targets)
clean:
	$(RM) $(toclean)

.for i in $(targets)
toclean += $(i) $($(i)_objs)
$(i): $($(i)_objs) $($(i)_deps)
	$(CC) $(LDFLAGS) $($(i)_ldflags) -o $(i) $($(i)_objs) $($(i)_libs)
.endfor
