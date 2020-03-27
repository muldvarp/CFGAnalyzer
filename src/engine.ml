open Basics ;;
open Problems ;;
open Satwrapper ;;
open Coding ;;

let bound_reached = ref false
let time_limit_reached = ref false
let time_out = ref (-1.0)
let maximum_bound = ref (-1)
 
let engine problem =
  let time = Sys.time () in
  let inc_level = ref 0 in

  let solver = Coding.Solver.get_solver () in

  let rec run_engine lower_k upper_k =
    if !maximum_bound > 0 && lower_k >= !maximum_bound 
    then (message 2 (fun _ -> "Search terminated because maximal bound of " ^ string_of_int !maximum_bound ^ 
                             " has been reached.\n");
          bound_reached := true)
    else if !time_out >= 0.0 && Sys.time () -. time > !time_out 
    then (message 2 (fun _ -> "Search terminated after time out occurred.\n");
          time_limit_reached := true)
    else (
    message 2 (fun _ -> "  Now testing length range [" ^ string_of_int (lower_k + 1) ^ ".." ^ 
                        string_of_int (upper_k + 1) ^ "].\n");
    message 2 (fun _ -> "    Creating constraints ...\n"); 
    let t = Sys.time () in
    List.iter
      (fun cm -> let constraints = cm lower_k upper_k in
                 List.iter
                   (fun c -> message 3 (fun _ -> "      adding clause " ^ showClause c ^ "\n");
                             solver#add_clause_array c)
                   constraints)
      problem.permanent;
    message 2 (fun _ -> "      permanent: " ^ Printf.sprintf "%.2f" (Sys.time () -. t) ^ "sec, now " ^ 
                        string_of_int (solver#clause_count) ^ " clauses, " ^ string_of_int (solver#literal_count) ^ 
                        " literals, " ^ string_of_int (solver#variable_count + solver#helper_variable_count) ^ " variables.\n"); 
    incr inc_level;
    let t = Sys.time () in
    List.iter
      (fun cm -> let constraints = cm lower_k upper_k in
                 List.iter
                   (fun c -> let c = Array.append c [| posEncode(Inc(!inc_level)) |] in
                             message 3 (fun _ -> "      adding clause " ^ showClause c ^ "\n");
                             solver#add_clause_array c)
                   constraints)
      problem.temporary;
    message 2 (fun _ -> "      temporary: " ^ Printf.sprintf "%.2f" (Sys.time () -. t) ^ "sec, now " ^ 
                        string_of_int (solver#clause_count) ^ " clauses, " ^ string_of_int (solver#literal_count) ^ 
                        " literals, " ^ string_of_int (solver#variable_count + solver#helper_variable_count) ^ " variables.\n"); 
    if !time_out >= 0.0 
    then (message 1 (fun _ -> "  setting time out limit currently unsupported\n")
          (* let t = max 0.01 (!time_out -. (Sys.time () -. time)) in
          message 2 (fun _ -> "  Setting time out limit for SAT solver to remaining " ^ 
                              Printf.sprintf "%.2f" t ^ "sec\n");
          (solver#set_timeout_limit t) *));
    message 2 (fun _ -> "  Solving ... ");
    let t = Sys.time () in
    solver#solve_with_assumptions [ negEncode(Inc(!inc_level)) ];
    message 2 (fun _ -> Printf.sprintf "%.2f" (Sys.time () -. t) ^ "sec\n");
    let r = solver#get_solve_result in
    match r with
          SolveSatisfiable -> 
               message 2 (fun _ -> "  ");
               message 1 (fun _ -> problem.positiveReport lower_k upper_k);
               solver#incremental_reset; 
	       if !continuous 
               then (message 2 (fun _ -> "  Deleting temporary constraints ... "); 
                     let t = Sys.time () in
                     solver#add_unit_clause (posEncode(Inc(!inc_level)));
                     message 2 (fun _ -> Printf.sprintf "%.2f" (Sys.time () -. t) ^ "sec.\n"); 
                     run_engine (upper_k + 1) (upper_k + !step_width))
        | SolveUnsatisfiable -> 
               message 2 (fun _ -> "  ");
               message 1 (fun _ -> problem.negativeReport lower_k upper_k);
               solver#incremental_reset; 
               message 2 (fun _ -> "  Deleting temporary constraints ... "); 
               let t = Sys.time () in
               solver#add_unit_clause (posEncode(Inc(!inc_level)));
               message 2 (fun _ -> Printf.sprintf "%.2f" (Sys.time () -. t) ^ "sec.\n"); 
               run_engine (upper_k + 1) (upper_k + !step_width)
(*	| SolveTimeout -> 
               message 2 (fun _ -> "SAT Solver timeout!\n"); exit 3
	| 5 -> message 2 (fun _ -> "SAT Solver aborted by user!\n"); exit 5
	| 4 -> message 2 (fun _ -> "SAT Solver ran out of memory!\n"); exit 4
	| 0 -> message 2 (fun _ -> "Undetermined answer from the SAT Solver!\n"); exit 6 *)
	| SolveFailure s -> 
               message 2 (fun _ -> "Solver failure: " ^ s ^ "\n"))
  in
  if (!start > 1)
  then (message 2 (fun _ -> "  Creating permanent constraints for range [1.." ^ string_of_int (!start-1) ^ "] ... "); 
        let t = Sys.time () in
        List.iter
          (fun cm -> let constraints = cm 0 (!start-2) in
                  List.iter
                    (fun c -> message 3 (fun _ -> "  Adding clause " ^ showClause c ^ "\n");
                              solver#add_clause_array c)
                    constraints)
          problem.permanent;
       message 2 (fun _ -> Printf.sprintf "%.2f" (Sys.time () -. t) ^ "sec.\n")); 
  run_engine (!start-1) (!start + !step_width - 2);
  message 2 (fun _ -> "Execution time: " ^ Printf.sprintf "%.2f" (Sys.time () -. time) ^ " seconds.\n");
  solver#dispose


  (* Varencoding.showAllValues ();
  if !bound_reached then exit 1;
  if !time_limit_reached then exit 2;
  exit 0   *)
