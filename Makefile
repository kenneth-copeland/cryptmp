PREFIX  ?= /usr/local
BINDIR  ?= $(PREFIX)/bin
SCRIPT  := cryptmp
TESTS   := $(wildcard tests/test-*.sh)
STAMP   := .tests-passed

.PHONY: install uninstall check-path test docker-test clean help

install: $(STAMP)
	@mkdir -p $(BINDIR)
	@if [ -w $(BINDIR) ]; then \
		cp $(SCRIPT) $(BINDIR)/$(SCRIPT); \
		chmod +x $(BINDIR)/$(SCRIPT); \
		echo "Installed $(SCRIPT) to $(BINDIR)/$(SCRIPT)"; \
	else \
		echo "$(BINDIR) is not writable."; \
		echo "Either run:"; \
		echo "  sudo make install"; \
		echo "Or install to your home directory:"; \
		echo "  make install PREFIX=~/.local"; \
		exit 1; \
	fi
	@$(MAKE) --no-print-directory check-path

$(STAMP): $(SCRIPT) $(TESTS) tests/run-tests.sh
	@tests/run-tests.sh
	@touch $(STAMP)

test: $(STAMP)

uninstall:
	rm -f $(BINDIR)/$(SCRIPT)
	@echo "Removed $(BINDIR)/$(SCRIPT)"

check-path:
	@case ":$$PATH:" in \
		*:$(BINDIR):*) ;; \
		*) \
			echo ""; \
			echo "Note: $(BINDIR) is not on your PATH. Add it with:"; \
			echo "  export PATH=\"$(BINDIR):\$$PATH\""; \
			;; \
	esac

docker-test:
	@tests/docker-tests.sh

docker-test-%:
	@tests/docker-tests.sh $*

clean:
	rm -f $(STAMP)

help:
	@echo "Usage:"
	@echo "  make install            Install to /usr/local/bin (may need sudo)"
	@echo "  make install PREFIX=DIR Install to DIR/bin"
	@echo "  make test               Run tests"
	@echo "  make docker-test        Run tests on all Linux distros"
	@echo "  make docker-test-ubuntu Run tests on a specific distro"
	@echo "  make clean              Remove test stamp (forces retest)"
	@echo "  make uninstall          Remove from $(BINDIR)"
