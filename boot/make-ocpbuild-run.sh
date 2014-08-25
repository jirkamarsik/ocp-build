#!/bin/sh

# Because ocaml-4.02 breaks bytecode compatibility, we have to build our 
# own runtime. What a shame !

OCAMLV=$(ocamlc -version)

LIBRUNTIME=
case ${OCAMLV} in
  4.02*ocp*) LIBRUNTIME="";;
  4.02*)
	(cd ocamlrun-4.02; ./configure; cd byterun; make)
	LIBRUNTIME="-I ocamlrun-4.02/byterun -cclib -lbyterun402";;
  *) LIBRUNTIME="";;
esac

echo ocamlc -o ocp-build.run -custom -make-runtime commonUnix_c.c primitives.ml unix.cma -cclib -lunix ${LIBRUNTIME}
ocamlc -o ocp-build.run -custom -make-runtime commonUnix_c.c primitives.ml unix.cma -cclib -lunix ${LIBRUNTIME}
