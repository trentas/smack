prefix ?= /usr/local

all: build-smack

install: install-smack

dist: build-smack

install-smack:
	-mkdir -p $(prefix)/bin
	cp dist/smack $(prefix)/bin/smack

build-smack:
	mkdir dist/
	echo "#!/usr/bin/env bash" > dist/smack
	cat LICENSE | sed 's/^/# /' >> dist/smack
	cat functions/* >> dist/smack
	cat "boot.sh" >> dist/smack
	chmod +x dist/smack

clean:
	@-rm -rf dist/
