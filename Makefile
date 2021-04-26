#######################################################
### change these to point to the right paths / commands
#######################################################

# command to copy a link into a file
CP=cp -L

#PDFLATEX=pdflatex

##################################################################
### no changes needed for the following under normal circumstances
##################################################################

OCAMLBUILD=ocamlbuild
OPTIONS=-use-ocamlfind
PACKAGES=-pkgs ocaml-sat-solvers
SRC=src
MAIN=main
INCLUDES=-I $(SRC)
LIBS=
PARAMS=$(INCLUDES) $(LIBS) $(PACKAGES)
EXECUTABLE=cfganalyzer

all: native

byte: 
	$(OCAMLBUILD) $(PARAMS) $(SRC)/$(MAIN).byte
	$(CP) $(MAIN).byte $(EXECUTABLE)

native: 
	$(OCAMLBUILD) $(PARAMS) $(SRC)/$(MAIN).native
	$(CP) $(MAIN).native $(EXECUTABLE)

clean:
	$(OCAMLBUILD) -clean

#doc: version
#	make -C doc


