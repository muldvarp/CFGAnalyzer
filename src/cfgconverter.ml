open Arg;;
open Cfg;;
open Printf;;

module CommandLine =
struct
  
  let tool = ref (-1)
  let input = ref ""
  let output = ref ""

  let dis = ref "symbol which delimits disjunctive right hand sides"
  let arrow = ref "symbol which delimits left and righthandside"
  let rule_end = ref "symbol which signals end of rule"
  let empty = ref "symbol for empty word"
  let token_delim = ref "symbol between terminals (or nonterminals)"

  let set_tool i =
    tool := i;
    token_delim := " ";
    if i = 0 then 
      (dis := "| ";
       arrow := ":\n";
       rule_end := "\n\n";
       empty := "/* empty */")
    else if i = 1 then 
      (dis := "| ";
       arrow := ":\n";
       rule_end := ";\n\n";
       empty := "/* empty */")

  let get_terminal s =
    let res = ref "" in 
      if !tool = 0 then
	res := "\"" ^ s ^ "\""
      else if !tool = 1 then
	res := "'" ^ s ^ "'";
      !res

  let get_nonterm s =
    if !tool = 0 then
      s
    else if !tool = 1 then
      s
    else s

  let set_acla _ = set_tool 0
  let set_amber _ = set_tool 1
  let set_output s = output := s

  let speclist = [ ("-acla", Unit(set_acla), "\n     output conform with the ACLA tool");
                   ("-amber", Unit(set_amber), "\n     output conform with the AMBER tool");
                   ("-o", String(set_output), "\n <filename>     specify an output file");
                 ]

  let header = "CFG Converter, version 29/1/2008\n\n"
end ;;

open CommandLine;;

let buffer = ref ""

let write_to_file _ =
  let oc = open_out !output in
    fprintf oc "%s\n" !buffer;  
    close_out oc

let rec process_stlf sf =
  match sf with
      [] -> ()
    | Nonterminal(s)::rest -> buffer := (!buffer ^ (get_nonterm s) ^ !token_delim); process_stlf rest
    | Terminal("")::rest -> buffer := (!buffer ^ !empty ^ !token_delim); process_stlf rest
    | Terminal(s)::rest -> buffer := (!buffer ^ (get_terminal s) ^ !token_delim); process_stlf rest

let rec process_rhs rhs =
  match rhs with
      [] -> failwith "Empty righthandside!"
    | stlform::[] -> process_stlf stlform; buffer := !buffer ^ !rule_end 
    | stlform::other -> process_stlf stlform; buffer := !buffer ^ "\n" ^ !dis; process_rhs other

let process_rule r =
  match r with 
      (lhs, rhs) -> buffer:=!buffer ^ lhs ^ !arrow; process_rhs rhs

let rec convert cfg =
  match cfg with 
      [] -> write_to_file ()
    | hdrule::tl -> process_rule hdrule; convert tl
  
let _ =
  parse speclist (fun f -> input := f) (header ^ "Usage: cfgconverter [options] <filename>\n" ^
                                              "Converts the given CFG into the format of another tool. For a list of available conversions type 'cfgconverter -help'");

  print_endline header;

  print_endline "Parsing\n"; 
  print_endline ("Reading CFG from \"" ^ !input ^ "\"\n");
  let in_channel = open_in !input in
  let lexbuf = Lexing.from_channel in_channel in
  let cfg = Parser.cfg Lexer.token lexbuf in 
    convert cfg

            
 
  
