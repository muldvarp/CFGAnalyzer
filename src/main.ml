open Cfg ;;
open Basics ;;
open Arg ;;
open Problems ;;
open Engine ;;
open Coding ;;

let problem = ref (None)
let cfgs = ref []

module CommandLine =
struct
  let set_verbosity i = if i >=0 && i <= 3 then verbosity := i
  let be_quiet _ = set_verbosity 0
  let be_verbose _ = set_verbosity 2
  let be_very_verbose _ = set_verbosity 3

  let input_files = ref [] 

  let set_problem p _ = 
    problem := Some p

  let set_output_file s =
    outputFile := s;
    writeOutput := true

  let set_time_out i = 
    time_out := float_of_int i

  let set_start i = 
    if i >= 1 then start := i

  let speclist = [ ("-v", Int(set_verbosity), "<level>\n     sets the verbosity level, valid arguments are 0-3, default is 1");
                   ("--quiet", Unit(be_quiet), "\n     causes the program to be quiet, same as `-v 0'");
                   ("--verbose", Unit(be_verbose), "\n     causes the program to be verbose, same as `-v 2'");
                   ("--debug", Unit(be_very_verbose), "\n     causes the program to be very verbose, same as `-v 3'");
                   ("-d", String(set_output_file), "<file>\n    causes parse trees (DAGs) to be written to <file> in dotty code"); 
                   ("-c", Set(continuous), "");
                   ("--continuous", Set(continuous), "\n     run continuously with increasing bounds, do not stop after first (counter)example");
                   ("-m", Set_int(maximum_bound), "");
                   ("--maxbound", Set_int(maximum_bound), "\n    sets the maximum length of words up to which witnesses/counterexamples are looked for");
                   ("-t", Int(set_time_out), "<secs>");
                   ("--timeout", Int(set_time_out), "<secs>\n    sets a time-out limit for the search specified in seconds");
                   ("-s", Set_int step_width, "");
                   ("--stepwidth", Set_int step_width, "\n    sets the stepwidth for checking ranges of word lengths, default is 1");
                   ("-b", Int set_start, "<k>");
                   ("--begin", Int set_start, "<k>\n    let the search begin with words of length k, where k >= 1; default is k=1");
                   ("-e",Unit(set_problem emptiness),"");
                   ("--emptiness",Unit(set_problem emptiness),"\n    checks whether L(G1) is not empty\n    a counterexample will be a word in L(G1)");
                   ("-u",Unit(set_problem universality),"");
                   ("--universality",Unit(set_problem universality),"\n    checks whether L(G1) is not universal\n    a counterexample will be a word not in L(G1)");
                   ("-i",Unit(set_problem inclusion),""); 
                   ("--inclusion",Unit(set_problem inclusion),"\n    checks whether L(G1) is not included in L(G2)\n    a counterexample will be a word w in L(G1) \\ L(G2)"); 
                   ("-n",Unit(set_problem intersection),""); 
                   ("--intersection",Unit(set_problem intersection),"\n    checks whether the intersection of L(G1), L(G2), ... is empty\n    an example will be a word w in all of them"); 
                   ("-q",Unit(set_problem equivalence),""); 
                   ("--equivalence",Unit(set_problem equivalence),"\n    checks whether L(G1)=L(G2)\n    a counterexample will be a word w in one language but not the other"); 
                   ("-a",Unit(set_problem ambiguity),""); 
                   ("--ambiguity",Unit(set_problem ambiguity),"\n    checks whether G1 is ambiguous\n    an example will be a word w in L(G1) which has two parse trees (use -o to have parse trees extracted)");
                   ("-o",String(Coding.Solver.set_solver),"");
                   ("--solver",String(Coding.Solver.set_solver),"<name>\n    sets <name> as the SAT solver, chose from " ^
                        (Coding.Solver.available_solvers ())) ]

  let header = "CFGAnalyzer, version 17/06/2020\n\n"
end ;;

open CommandLine ;;

let _ =
  message 1 (fun _ -> header);

  parse speclist (fun f -> input_files := f :: !input_files) (header ^ "Usage: cfganalyzer [options] <file1> [<file2> <file3> ...]\n" ^
                                              "Analyzes the CFGs given in <file1> and possibly <file2>, etc. These are assumed to contain CFGs G1,G2,...\n\nOptions are");

  message 2 (fun _ -> "Parsing input grammars ...\n");
  let number = ref 0 in 
  cfgs := List.map (fun file -> 
            message 2 (fun _ -> "  reading CFG no. " ^ string_of_int !number ^ " from \"" ^ file ^ "\"\n");
            let in_channel = open_in file in
            let lexbuf = Lexing.from_channel in_channel in
            let cfg = try
                        Parser.cfg Lexer.token lexbuf 
                      with
                        Parsing.Parse_error -> begin
                                                 let curr = lexbuf.Lexing.lex_curr_p in
                                                 let line = curr.Lexing.pos_lnum in
                                                 let cnum = curr.Lexing.pos_cnum - curr.Lexing.pos_bol in
                                                 let tok = Lexing.lexeme lexbuf in
                                                 (* let tail = Sql_lexer.ruleTail "" lexbuf in *) 
                                                 print_string ("Parsing error in line " ^ string_of_int line ^ " at position " ^ 
                                                                string_of_int cnum ^ ": " ^ tok ^ "\n");
                                                 exit 1
                                               end
            in
            message 3 (fun _ -> "    CFG:\n" ^ Cfg.showPureCFG cfg ^ "\n");
            let (e,t,u,c,r,z,a) = size cfg in
            message 3 (fun _ -> "CFG grammar size: " ^ string_of_int e ^ " " ^ string_of_int t ^ " " ^ string_of_int u ^ " " 
                                ^ string_of_int c ^ " " ^ string_of_int r ^ " " ^ string_of_int z ^ " " ^ string_of_int a ^ "\n");
            let cfg = Cfg.makeFullCFG cfg !number in
            message 3 (fun _ -> "    CFG no. " ^string_of_int !number ^ " in 2NF:\n" ^ Cfg.showPureCFG cfg.cfg ^ "\n");
            message 3 (fun _ -> "    Alphabet: {" ^ String.concat "," cfg.alphabet ^ "}\n\n");
            message 3 (fun _ -> "    Nonterminals: {" ^ String.concat "," cfg.nonterminals ^ "}\n\n");
            message 3 (fun _ -> "    Ambiguous nonterminals: {" ^ String.concat "," (StringSet.elements cfg.ambnonterminals) ^ "}\n\n");
(*            message 3 (fun _ -> "    Nullable symbols: {" ^ 
                                String.concat 
                                  "," 
                                  (StringSet.fold (fun x -> fun l -> x::l) cfg.nullable []) 
                                ^ "}\n\n");
            message 3 (fun _ -> "    Nullable symbols (with ambiguity information): {" ^ 
                                String.concat 
                                  "," 
                                  (StringIntSet.fold 
                                     (fun (x,i) -> fun l -> ("(" ^ x ^ "," ^ string_of_int i ^ ")")::l) 
                                     cfg.ambnullable []) 
                                ^ "}\n\n");
            message 3 (fun _ -> "    Unit production hull:\n" ^ Cfg.showUnitProdClosure cfg.closure ^ "\n");
            message 3 (fun _ -> "    Unit production hull (with ambiguity information):\n" ^ 
                                Cfg.showAmbUnitProdClosure cfg.ambclosure ^ "\n");
            message 3 (fun _ -> "Terminal productions:\n" ^ String.concat "" (List.map 
                        (fun (a,ts) -> "  " ^ a ^ " -> {" ^ String.concat "," ts ^ "}\n") 
                        cfg.termprods) ^ "\n"); *)
            let (e,t,u,c,r,z,a) = size cfg.cfg in
            message 3 (fun _ -> "2NF grammar size: " ^ string_of_int e ^ " " ^ string_of_int t ^ " " ^ string_of_int u ^ " " 
                                ^ string_of_int c ^ " " ^ string_of_int r ^ " " ^ string_of_int z ^ " " ^ string_of_int a ^ "\n");
            incr number;
            cfg) 
            (List.rev !input_files);

  message 2 (fun _ -> "Checking whether proper SAT solver needs to be chosen ...\n");
  Coding.Solver.find_proper_solver ();
  message 2 (fun _ -> "  available: " ^ Coding.Solver.available_solvers () ^ 
                      "\n  chosen: " ^ Coding.Solver.get_solver_name () ^ "\n");
  match !problem with 
    Some p -> let pr = p !cfgs in
              message 2 (fun _ -> "Starting the engine for problem `" ^ pr.identifier ^ "'.\n"); 
              Engine.engine pr
  | None   -> message 2 (fun _ -> "No problem chosen. I'm done. That was easy.\n")
