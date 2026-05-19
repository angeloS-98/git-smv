# git-smv — Git Submodule Versioning
PREFIX ?= $(HOME)/.local
BINDIR ?= $(PREFIX)/bin
DATADIR ?= $(PREFIX)/share
LIBDIR = $(DATADIR)/git-smv
MANPREFIX ?= $(PREFIX)
mandir = $(MANPREFIX)/share/man
MAN1DIR = $(mandir)/man1

.PHONY: all install install-bin install-lib install-man install-exec test lint clean uninstall

all:

install: install-bin install-lib install-man

install-bin:
	@mkdir -p "$(BINDIR)"
	@install -m 755 git-smv "$(BINDIR)/git-smv"
	@echo "Installed $(BINDIR)/git-smv"

install-lib:
	@mkdir -p "$(LIBDIR)/lib/commands"
	@install -m 644 lib/git-sh-setup.sh lib/common.sh lib/lockfile.sh \
		lib/gitmodules.sh lib/checks.sh lib/smv-lib-root.sh "$(LIBDIR)/lib/"
	@install -m 644 lib/commands/*.sh "$(LIBDIR)/lib/commands/"
	@echo "Installed $(LIBDIR)/lib/"

install-man:
	@mkdir -p "$(MAN1DIR)"
	@install -m 644 man/git-smv.1 "$(MAN1DIR)/git-smv.1"
	@echo "Installed $(MAN1DIR)/git-smv.1"

install-exec:
	@execpath=$$(git --exec-path); \
	prefix=$$(CDPATH= cd "$$execpath/.." && pwd); \
	$(MAKE) install-lib PREFIX="$$prefix"; \
	install -m 755 git-smv "$$execpath/git-smv"; \
	echo "Installed $$execpath/git-smv and $$prefix/share/git-smv/lib/"

uninstall:
	@rm -f "$(BINDIR)/git-smv" "$(MAN1DIR)/git-smv.1"
	@rm -rf "$(LIBDIR)"
	@echo "Uninstalled git-smv from $(PREFIX)"

test:
	@cd t && PATH="$(CURDIR):$$PATH" prove -v ./t[0-9]*.sh

lint:
	@command -v shellcheck >/dev/null 2>&1 || { echo "shellcheck not installed, skipping"; exit 0; }; \
	shellcheck git-smv lib/*.sh lib/commands/*.sh t/*.sh

clean:
	@rm -rf t/trash_directory.*
