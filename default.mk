# default.mk -- default makefile rules to use variable
# 				targets, <target>_objs, <target>_deps,
#				<target>_cflags, <target>_ldflags,
#				<target>_libs
# Author: Luis Colorado <luiscoloradourcola@gmail.com>
# Date: Wed May  9 09:41:08 EEST 2018

RM ?= rm -f

all: $(targets) SUB .PHONY
clean: SUB .PHONY
	$(RM) $(toclean)
depend: SUB .PHONY ./*.c
.if !empty($?)
	-mkdep $?
.endif

SUB: .USEBEFORE .MAKE
.if defined(SUBDIRS)
	for i in $(SUBDIRS); \
	do $(MAKE) -C $$i $(.TARGET); \
	done
.endif

.c.o:
	$(CC) $(CFLAGS) $($@_cflags) -o $@ -c $<

.for i in $(targets)
toclean += $(i) $($(i)_objs)
$(i): $($(i)_objs) $($(i)_deps)
	$(CC) $(LDFLAGS) $($(i)_ldflags) -o $(i) $($(i)_objs) $($(i)_libs)
.endfor
