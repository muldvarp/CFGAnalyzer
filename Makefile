#OCAMLBUILD=ocamlbuild -verbose 3
OCAMLBUILD=ocamlbuild
OPTIONS=-use-ocamlfind
PACKAGES=-pkgs ocaml-sat-solvers
SRC=src
MAIN=main
#INCLUDES=-I $(SRC) -I ocaml-sat-solvers/_build/src -I ocaml-sat-solvers/_build/src/internalsat -I ocaml-satsolvers/_build/src/minisat
INCLUDES=-I $(SRC)
#LIBS=-lib unix
LIBS=
PARAMS=$(INCLUDES) $(LIBS) $(PACKAGES)
#SED=sed

#PDFLATEX=/usr/local/texlive/2018/bin/x86_64-darwin/pdflatex


all: byte native

#byte: version
byte: 
	$(OCAMLBUILD) $(PARAMS) $(SRC)/$(MAIN).byte

#native: version
native: 
	$(OCAMLBUILD) $(PARAMS) $(SRC)/$(MAIN).native

clean:
	$(OCAMLBUILD) -clean

#archive: version
#	zip dimo.zip src/alschemes.ml src/basics.ml src/dimo.ml src/engine.ml src/enumerators.ml \
#	src/lexer.mll src/parser.mly src/propFormula.ml src/version.ml \
#	examples/exactlyMofN.dm examples/nQueens.dm Makefile _tags README

#doc: version
#	make -C doc

#version:
#	$(SED) "s/[0-9,\.]*/let version=\"&\"/" Version.txt > src/version.ml
#	$(SED) "s/[0-9,\.]*/\\\newcommand\{\\\DiMoVersion\}\{&\}/" Version.txt > doc/version.tex

