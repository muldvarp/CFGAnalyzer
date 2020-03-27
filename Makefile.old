ifeq ($(strip $(wildcard Config)),)
        include Config.default
else
        include Config
endif

OBJDIR=obj
SRCDIR=src
BINDIR=bin
SATSOLVERSOBJ=$(SATSOLVERSROOT)/obj

INCLUDES=-I $(SRCDIR) \
         -I $(OBJDIR) \
         -I $(SATSOLVERSOBJ) \
         -I $(OCAML_DIR)

include $(SATSOLVERSROOT)/Config.include

MODULES=obj/basics.cmx \
        obj/cfg.cmx \
        obj/parser.cmx \
        obj/lexer.cmx \
        obj/coding.cmx \
        obj/dotty.cmx \
        obj/problems.cmx \
        obj/engine.cmx

SATSOLVERMODULES=$(SATSOLVERSOBJ)/satwrapper.cmx \
                 $(SATSOLVERSOBJ)/satsolvers.cmx \
                 $(SATSOLVERSOBJ)/pseudosatwrapper.cmx \
                 $(SATSOLVERMODS)

INTERFACES=$(MODULES:.cmx=.cmi)

EXECUTABLE=$(BINDIR)/cfganalyzer


$(SOURCES:.ml=.cmx:src=obj)


all: satsolvers $(INTERFACES) $(MODULES) obj/main.cmx exec

satsolvers:
	make -C $(SATSOLVERSROOT)

src/parser.ml: src/parser.mly
	$(OCAMLYACC) src/parser.mly

obj/parser.cmi: src/parser.mli
	$(OCAMLOPT) $(INCLUDES) -c -o obj/parser.cmi src/parser.mli

src/lexer.ml: src/lexer.mll
	$(OCAMLLEX) src/lexer.mll

exec:
	$(OCAMLOPT) -o $(EXECUTABLE) -cc $(CPP) $(SATSOLVERMODULES) $(MODULES) obj/main.cmx

obj/%.cmx: src/%.ml
	$(OCAMLOPT) $(INCLUDES) -c -o $@ $<

obj/%.cmi: src/%.mli
	$(OCAMLOPT) $(INCLUDES) -c -o $@ $<

#src/%.mli: src/%.ml
#	$(OCAMLOPT) $(INCLUDES) -i $< > $@

src/lexer.mli: src/lexer.ml
	$(OCAMLOPT) $(INCLUDES) -i src/lexer.ml > src/lexer.mli

src/parser.mli: src/parser.ml
	$(OCAMLOPT) $(INCLUDES) -i src/parser.ml > src/parser.mli

#src/basics.mli: src/basics.ml
#	$(OCAMLOPT) $(INCLUDES) -i src/basics.ml > src/basics.mli

obj/%.cmi: src/%.mli
	$(OCAMLOPT) $(INCLUDES) -c -o $@ $<

clean:
	rm -f obj/*.o obj/*.cmx obj/*.cmi
	rm -f src/parser.ml src/parser.mli src/lexer.ml src/lexer.mli
	rm -f $(EXECUTABLE)

veryclean: clean
	make -C $(SATSOLVERSROOT) clean

depend:
	$(OCAMLDEP) -native $(INCLUDES) src/*.mli src/*.ml | $(SED) "s/src/obj/g" > .depend


include .depend
