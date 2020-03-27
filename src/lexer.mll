(* File lexer.mll *)

{
open Parser        (* The type token is defined in parser.mli *)

let row = ref 1
let col = ref 1

let process = function '\n' -> incr row; col := 1
                     | '\r' -> col := 1
	             | '\b' -> if !col > 1 then decr col
	             | _    -> incr col

let process_s = String.iter process

}

rule token = parse
    [' ' '\t' '\n' '\r'] as c                                { process c; token lexbuf }
  | "/*" ([^ '*']* | ([^ '*']* '*' [^ '/'])*) "*/" as s      { process_s s; token lexbuf }
  | ':'                                                      { let c = !col in incr col; Colon(!row,c) }
  | ';'                                                      { let c = !col in incr col; Semicolon(!row,c) }
  | eof                                                      { let c = !col in incr col; EOF(!row,c) }
  | '"'((_ # '"')* as terminal)'"' as s                      { let c = !col in 
                                                               let r = !row in 
                                                               process_s s; Terminal(r,c,terminal) }
  | '['(_ # ']')*']' as s                                    { let c = !col in
                                                               let r = !row in 
                                                               process_s s; Name(r,c) }
  | (_ # [' ' '\t' '\n' ';' ':' '"' '[' ']' '\r'])* as s     { let c = !col in
                                                               let r = !row in
                                                               process_s s; String(r,c,s) }

