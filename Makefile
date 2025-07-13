prefix ?= /usr/local
bindir := $(prefix)/bin
distfile := dist/smack

all: build

build: $(distfile)

install: build
	install -Dm755 $(distfile) $(bindir)/smack

uninstall:
	rm -f $(bindir)/smack

$(distfile): boot.sksh $(wildcard functions/*.sksh) LICENSE
	@mkdir -p dist
	@echo "#!/usr/bin/env bash" > $(distfile)
	@sed 's/^/# /' LICENSE >> $(distfile)
	@cat functions/*.sksh >> $(distfile)
	@cat boot.sksh >> $(distfile)
	@chmod +x $(distfile)

clean:
	@rm -rf dist

