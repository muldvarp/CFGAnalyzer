/* File parser.mly */
%{

open Cfg

%}

%token <int * int> Colon
%token <int * int> Semicolon
%token <int * int> Quotes
%token <int * int> Name
%token <int * int * string> String
%token <int * int * string> Terminal
%token <int * int> EOF

%start cfg
%type <Cfg.pureCFG> cfg
%%

cfg:
    EOF                                         { [] }
  | vardecl cfg                                 { $1 :: $2 }
;
 
vardecl:
    nonterminal rules                           { ($1,$2) }
;

nonterminal:
    String                                      { let (_,_,s) = $1 in s }
;

rules:
    rule                                        { [ $1 ] }
  | rule rules                                  { $1 :: $2 }
;

rule:
    rulename Colon symbollist Semicolon         { $3 }
;

rulename:
    Name                                        { () }
  |                                             { () }
;

symbollist:
    symbol symbollist                           { $1 :: $2 }
  |                                             { [] }
;

symbol:
    String                                      { let (_,_,s) = $1 in Nonterminal(s) }
  | Terminal                                    { let (_,_,s) = $1 in Terminal(s) }
;


%%




