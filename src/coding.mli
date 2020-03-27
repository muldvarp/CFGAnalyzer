open Cfg ;;
open Basics ;;

type variable = T of (string * int)      
              | T' of (string * int)      
              | N of (fullCFG * string * int * int)
              | H of (fullCFG * string * string * int * int * int)
              | B of int
              | B' of int
              | Two of (string * int * int)
              | One of (string * int * int)
	      | A of (fullCFG * string * int * int)
	      | AO of (string * int * int * int)
	      | AT of (string * int * int * int)
	      | ATH of (string * string * int * int * int)
	      | AOH of (string * string * int * int * int)
              | Inc of int

val showVar : variable -> string
val showClause : variable Satwrapper.literal array -> string

val posEncode : variable -> variable Satwrapper.literal 
val negEncode : variable -> variable Satwrapper.literal 

type constraints = variable Satwrapper.literal array list

(*
val getCode   : variable -> int
*)

(* exception Variable_unknown_to_zchaff of string *)

module Solver :
sig

  val get_solver : unit -> variable Satwrapper.satWrapper 

  val get_solver_name : unit -> string

  val set_solver : string -> unit

  val available_solvers : unit -> string

  val find_proper_solver : unit -> unit

end ;;

val getValue : variable -> int

(*
val showAllValues : unit -> unit
*)

val unique_symbols                             : alphabet -> int -> int -> constraints
val composition_topdown                        : fullCFG -> int -> int -> constraints
val composition_bottomup                       : fullCFG -> int -> int -> constraints
(*
val closure_topdown                            : fullCFG -> int -> int -> constraints
val closure_bottomup                           : fullCFG -> int -> int -> constraints
*)
val derivable                                  : fullCFG -> int -> int -> constraints 
val underivable                                : fullCFG -> int -> int -> constraints 
(*
val base_topdown                               : fullCFG -> int -> int -> constraints 
val base_bottomup                              : fullCFG -> int -> int -> constraints 
*)
val derives_one_but_not_the_other              : int -> int -> constraints 
val derives_one_but_not_the_other_implications : fullCFG -> fullCFG -> int -> int -> constraints 
val derives_exactly_one                        : int -> int -> constraints
val derives_exactly_one_implications           : fullCFG -> fullCFG -> int -> int -> constraints
val all_derivable                              : int -> int -> constraints 
val all_derivable_implications                 : fullCFG list -> int -> int -> constraints 
val two_productions                            : fullCFG -> int -> int -> constraints

(*
val ambiguity_base                             : fullCFG -> int -> int -> constraints
val ambiguity_derivable                        : fullCFG -> int -> int -> constraints
val ambiguity_closure                          : fullCFG -> int -> int -> constraints
val ambiguity_composition                      : fullCFG -> int -> int -> constraints
*)





(*
val retrieve_derived_word   : fullCFG -> int -> int -> string
val retrieve_underived_word : fullCFG -> int -> int -> string
*)
