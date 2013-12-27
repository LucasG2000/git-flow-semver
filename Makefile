#
#

prefix=/usr/local

bindir=$(prefix)/bin
hooksdir=$(bindir)/gitflow-semver-hooks

# files that need mode 644
SCRIPT_FILES=git-flow-semver

all:
	@echo "usage: make install"
	@echo "       make uninstall"

install:
	install -d -m 0755 $(bindir)
	install -d -m 0755 $(hooksdir)
	install -m 0644 $(SCRIPT_FILES) $(bindir)

	(cp -r hooks/* $(hooksdir)/)

uninstall:
	test -d $(bindir) && \
	cd $(bindir) && \
	rm -f $(SCRIPT_FILES)
	test -d $(hooksdir) && \
	rm -rf $(hooksdir)
