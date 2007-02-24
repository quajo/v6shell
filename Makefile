# Makefile for osh-current (20070224)

#
# Begin CONFIGURATION
#
# Adjust the following variables as needed to match your desires
# and/or the requirements of your system.
#

#
# If your system has a login(1) utility, what is its path name?
# This is the utility used by the shell's `login' special command
# to replace an interactive shell with an instance of login(1).
#
PATH_LOGIN?=	/usr/bin/login

#
# If your system has a newgrp(1) utility, what is its path name?
# This is the utility used by the shell's `newgrp' special command
# to replace an interactive shell with an instance of newgrp(1).
#
PATH_NEWGRP?=

#
# Build utilities
#
#CC=		/usr/bin/cc
INSTALL=	/usr/bin/install

#
# Compiler and linker flags
#
CFLAGS+=	-O2
CFLAGS+=	-std=c99
CFLAGS+=	-pedantic
#CFLAGS+=	-g
CFLAGS+=	-Wall -W
#LDFLAGS+=	-static

#
# Choose where and how to install the binaries and manual pages.
#
PREFIX?=	/usr/local
BINDIR?=	$(PREFIX)/bin
MANDIR=		$(PREFIX)/man
SYSCONFDIR?=	/etc
#BINGRP=		-g bin
BINMODE=	-m 0555
#MANGRP=		-g bin
MANMODE=	-m 0444

#
# End CONFIGURATION
#

#
# X/Open System Interfaces Extension (NOTES: POSIX, required)
#
XSIE=		-D_XOPEN_SOURCE=600

#
# The following specifies the osh version:
#	osh-YYYYMMDD		== official release
#	osh-current (YYYYMMDD)	== current development snapshot
#
OSH_VERSION=	osh-current (20070224)

OSH=	osh
SH6=	sh6 glob6
UTILS=	if goto fd2
PEXSRC=	pexec.h pexec.c
OBJ=	pexec.o osh.o sh6.o glob6.o if.o goto.o fd2.o
MANSRC=	osh.1.src sh6.1.src glob6.1.src if.1.src goto.1.src fd2.1.src
MANDST=	osh.1 sh6.1 glob6.1 if.1 goto.1 fd2.1

DEFS=	-D_PATH_LOGIN='"$(PATH_LOGIN)"' -D_PATH_NEWGRP='"$(PATH_NEWGRP)"'
DEFS+=	-DSYSCONFDIR='"$(SYSCONFDIR)"' -DOSH_VERSION='"$(OSH_VERSION)"'

.c.o:
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $(XSIE) $(DEFS) $<

#
# Build targets
#
all: oshall sh6all

oshall: $(OSH) utils man

sh6all: $(SH6) utils man

utils: $(UTILS)

osh: version.h $(PEXSRC) osh.c
	@$(MAKE) $@bin

sh6: version.h $(PEXSRC) sh6.c
	@$(MAKE) $@bin

glob6: version.h $(PEXSRC) glob6.c
	@$(MAKE) $@bin

if: version.h $(PEXSRC) if.c
	@$(MAKE) $@bin

goto: version.h goto.c
	@$(MAKE) $@bin

fd2: version.h $(PEXSRC) fd2.c
	@$(MAKE) $@bin

$(OBJ): version.h
pexec.o: $(PEXSRC)
osh.o sh6.o glob6.o if.o fd2.o: pexec.h

oshbin: pexec.o osh.o
	$(CC) $(LDFLAGS) -o osh osh.o pexec.o $(LIBS)

sh6bin: pexec.o sh6.o
	$(CC) $(LDFLAGS) -o sh6 sh6.o pexec.o $(LIBS)

glob6bin: pexec.o glob6.o
	$(CC) $(LDFLAGS) -o glob6 glob6.o pexec.o $(LIBS)

ifbin: pexec.o if.o
	$(CC) $(LDFLAGS) -o if if.o pexec.o $(LIBS)

gotobin: goto.o
	$(CC) $(LDFLAGS) -o goto goto.o $(LIBS)

fd2bin: pexec.o fd2.o
	$(CC) $(LDFLAGS) -o fd2 fd2.o pexec.o $(LIBS)

#
# Manual-page targets
#
man: $(MANDST)
$(MANDST): $(MANSRC)
	@for file in $(MANSRC) ; do sed \
		-e 's,@OSH_VERSION@,$(OSH_VERSION),' \
		-e 's,@SYSCONFDIR@,$(SYSCONFDIR),' <$$file >$${file%.src} ; \
	done

#
# Install targets
#
install: install-oshall install-sh6all

install-oshall: $(OSH) utils man install-osh install-utils

install-sh6all: $(SH6) utils man install-sh6 install-utils

install-osh: $(OSH) man install-dest
	$(INSTALL) -c -s $(BINGRP) $(BINMODE) osh     $(DESTDIR)$(BINDIR)
	$(INSTALL) -c    $(MANGRP) $(MANMODE) osh.1   $(DESTDIR)$(MANDIR)/man1

install-sh6: $(SH6) man install-dest
	$(INSTALL) -c -s $(BINGRP) $(BINMODE) sh6     $(DESTDIR)$(BINDIR)
	$(INSTALL) -c    $(MANGRP) $(MANMODE) sh6.1   $(DESTDIR)$(MANDIR)/man1
	$(INSTALL) -c -s $(BINGRP) $(BINMODE) glob6   $(DESTDIR)$(BINDIR)
	$(INSTALL) -c    $(MANGRP) $(MANMODE) glob6.1 $(DESTDIR)$(MANDIR)/man1

install-utils: utils man install-dest
	$(INSTALL) -c -s $(BINGRP) $(BINMODE) if      $(DESTDIR)$(BINDIR)
	$(INSTALL) -c    $(MANGRP) $(MANMODE) if.1    $(DESTDIR)$(MANDIR)/man1
	$(INSTALL) -c -s $(BINGRP) $(BINMODE) goto    $(DESTDIR)$(BINDIR)
	$(INSTALL) -c    $(MANGRP) $(MANMODE) goto.1  $(DESTDIR)$(MANDIR)/man1
	$(INSTALL) -c -s $(BINGRP) $(BINMODE) fd2     $(DESTDIR)$(BINDIR)
	$(INSTALL) -c    $(MANGRP) $(MANMODE) fd2.1   $(DESTDIR)$(MANDIR)/man1

install-dest:
	test -d $(DESTDIR)$(BINDIR) || { \
		umask 0022 ; mkdir -p $(DESTDIR)$(BINDIR) ; \
	}
	test -d $(DESTDIR)$(MANDIR)/man1 || { \
		umask 0022 ; mkdir -p $(DESTDIR)$(MANDIR)/man1 ; \
	}

#
# Cleanup targets
#
clean-obj:
	rm -f $(OBJ)

clean: clean-obj
	rm -f $(OSH) $(SH6) $(UTILS) $(MANDST)