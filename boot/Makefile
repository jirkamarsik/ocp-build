PREFIX?=/usr/local/
OCAMLC?=ocamlc

OCAMLC:=$(HOME)/.opam/4.02.0+beta1/bin/ocamlc

ocp-build: primitives ocp-build.boot commonUnix_c.c
	awk '{ print "external "$$1": unit -> unit = \"" $$1 "\"" }' primitives > primitives.ml
	./make-ocpbuild-run.sh
	cat ocp-build.run ocp-build.boot > ocp-build
	chmod +x ocp-build
	./ocp-build -help >/dev/null 2>&1

install: ocp-build
	cp ocp-build $(PREFIX)/bin/ocp-build

clean:
	cd ocamlrun-4.02; $(MAKE) clean
	rm -f *~ ocp-build ocp-build.run primitives.cm? commonUnix_c.o commonUnix_c.obj primitives.ml

