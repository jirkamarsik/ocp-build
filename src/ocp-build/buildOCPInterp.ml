(******************************************************************************)
(*                                                                            *)
(*                          TypeRex OCaml Tools                               *)
(*                                                                            *)
(*                               OCamlPro                                     *)
(*                                                                            *)
(*    Copyright 2011-2012 OCamlPro                                            *)
(*    All rights reserved.  See accompanying files for the terms under        *)
(*    which this file is distributed. In doubt, contact us at                 *)
(*    contact@ocamlpro.com (http://www.ocamlpro.com/)                         *)
(*                                                                            *)
(******************************************************************************)

(* open BuildBase *)
(* open Stdlib2 *)
open BuildOCPVariable
open BuildOCPTree
open BuildOCPTypes



type config = {
  config_env : BuildOCPVariable.env;
  config_configs : set_option list StringMap.t;
  config_dirname : string;
  config_filename : string;
}

type state = {
  mutable packages : package IntMap.t;
  mutable npackages : int;
}


let meta_options = [
  "o",      [ "dep"; "bytecomp"; "bytelink"; "asmcomp"; "asmlink" ];
  "oc",      [ "bytecomp"; "bytelink"; "asmcomp"; "asmlink" ];
  "byte",   [        "bytecomp"; "bytelink"; ];
  "asm",   [        "asmcomp"; "asmlink"; ];
  "comp",   [        "bytecomp"; "asmcomp"; ];
  "link",   [        "bytelink"; "asmlink"; ];
]


let initial_state () =
{ packages = IntMap.empty; npackages = 0; }

let final_state state =
  if state.npackages = 0 then [||] else
    Array.init state.npackages (fun i ->
      IntMap.find i state.packages
    )

let new_package pj name dirname filename kind =
  let package_id = pj.npackages in
  pj.npackages <- pj.npackages + 1;
  let pk = {
    package_source_kind = "ocp";
    package_id = package_id;
    package_tag = "";
    package_auto = None;
    package_version = "";
    package_loc = (-1);
    package_filename = filename;
    package_node = LinearToposort.new_node ();
    package_added = false;
    package_requires = [];
    package_name = name;
    package_missing_deps = 0;
    package_provides = name;
    package_type = kind;
(*    package_native = true; *)
    package_validated = false;
    package_raw_files = [];
    package_raw_tests = [];
    package_files = [];
    package_tests = [];
    package_dirname = dirname;
    package_deps_map = StringMap.empty;
(*    package_deps_sorted = []; *)
    package_options = empty_env;
(*    package_cflags = ""; *)
(*    package_cclib = ""; *)
(*    package_details = None; *)
(*    package_has_byte = true; *)
    package_has_byte_debug = false;
(*    package_has_asm = true; *)
    package_has_asm_debug = false;
    package_has_asm_profile = false;
  } in
  pj.packages <- IntMap.add pk.package_id pk pj.packages;
  pk

(*
let empty_config set_defaults =
  let options = BuildOCPVariable.new_options in
  let options =
    List.fold_left (fun vars f -> f vars)
      options set_defaults
  in
  {
    config_parent = None;
    config_variables = options;
    config_configs = StringMap.empty;
    config_dirname = "";
    config_filename = "";
  }
*)

let empty_config = {
  config_env = empty_env;
  config_configs = StringMap.empty;
  config_dirname = "";
  config_filename = "";
}

let generated_config = {
  empty_config with
  config_env = BuildOCPVariable.set_bool empty_config.config_env "generated" true;
}

(*
let configs = Hashtbl.create 17
*)

let define_config config config_name options =
  { config with config_configs = StringMap.add config_name options config.config_configs }

let find_config config config_name =
  try
    StringMap.find config_name config.config_configs
  with Not_found ->
    Printf.eprintf "Error: configuration %S not found\n" config_name;
    exit 2

(*
let option_list_set options name list =
      StringMap.add name (option_value_of_strings list) options


let option_bool_set options name bool =
  StringMap.add name (option_value_of_bool bool) options

let rec option_list_remove prev list =
  match list with
      [] -> prev
    | first_ele :: next_eles ->
      let rec iter prev before =
        match prev with
            [] -> List.rev before
          | x :: tail ->
            if x = first_ele then
              cut_after x tail tail next_eles before
            else
              iter tail (x :: before)

      and cut_after head tail list1 list2 before =
        match list1, list2 with
            _, [] -> iter list1 before
          | x1 :: tail1, x2 :: tail2 when x1 = x2 ->
            cut_after head tail tail1 tail2 before
          | _ -> iter tail (head :: before)
      in
      iter prev []

let option_list_remove options name list =
  try
    match StringMap.find name options with
	OptionList prev ->
          let new_list = option_list_remove prev list in
          StringMap.add name (OptionList new_list) options
      | _ ->
	failwith  (Printf.sprintf "OptionListRemove %s: incompatible values" name);
  with Not_found -> options



let option_list_append options name list =
  let list =
    try
      match StringMap.find name options with
	  OptionList prev -> prev @ list
	| _ ->
	  failwith  (Printf.sprintf "OptionListAppend %s: incompatible values" name);
    with Not_found -> list
  in
  StringMap.add name (OptionList list) options

let options_list_append options names list =
  List.fold_left (fun options var ->
    option_list_append options var list
  ) options names

let options_list_remove options names list =
  List.fold_left (fun options var ->
    option_list_remove options var list
  ) options names

let options_list_set options names list =
  List.fold_left (fun options var ->
    option_list_set options var list
  ) options names

let meta_options =
  let list = ref StringMap.empty in
  List.iter (fun (name, names) -> list := StringMap.add name names !list) meta_options;
  !list

let option_list_set options name list =
  try
    let names = StringMap.find name meta_options in
    options_list_set options names list
  with Not_found -> option_list_set options name list

let option_list_append options name list =
  try
    let names = StringMap.find name meta_options in
    options_list_append options names list
  with Not_found -> option_list_append options name list


let option_list_remove options name list =
  try
    let names = StringMap.find name meta_options in
    options_list_remove options names list
  with Not_found -> option_list_remove options name list


let generated_config set_defaults =
  let config = empty_config set_defaults in
  { config with config_options = option_bool_set config.config_options
    "generated" true }

*)


(*
  module MakeParser(BuildGlobals : sig

  type project_info

  val new_project_id : unit -> int
  val register_project : project_info  BuildOCPTypes.project -> unit
  val new_project :
(* project name *) string ->
(* project dirname *) string ->
(* configuration filename *) string ->
  project_info BuildOCPTypes.project

  val register_installed : string -> unit

  end) = struct
*)


let new_package_dep pk s =
    try
      StringMap.find s pk.package_deps_map
    with Not_found ->
      let dep = {
        dep_project = s;
        dep_link = false;
        dep_syntax = false;
        dep_optional = false;
      }
      in
      pk.package_deps_map <- StringMap.add s dep pk.package_deps_map;
      dep

let add_project_dep pk s options =
  let dep = new_package_dep pk s in
  dep.dep_link <- get_bool_with_default options "link" true;

(*
  begin
    try
      match StringMap.find "syntax" options with
        OptionBool bool -> dep.dep_syntax <- bool
      | _ ->
        Printf.fprintf stderr "Warning: option \"syntax\" is not bool !\n%!";
    with Not_found -> ()
  end;
*)

  begin
    try
      dep.dep_optional <- get_bool options "optional"
    with Not_found -> ()
  end;
(*  Printf.eprintf "add_project_dep for %S = %S with link=%b\n%!"
    pk.package_name s dep.dep_link; *)
()

let define_package pj name config kind =
  let dirname =
    try
      let list = get_strings config.config_env "dirname"  in
      BuildSubst.subst_global (String.concat Filename.dir_sep list)
    with Not_found ->
      config.config_dirname
  in

  let pk = new_package pj name
    dirname config.config_filename kind
  in
  let project_options = config.config_env in
(*  pk.package_raw_files <-  config.config_files; *)
(*  pk.package_raw_tests <- config.config_tests; *)
  pk.package_options <- project_options;
  pk.package_version <- get_string_with_default project_options "version"
    "0.1-alpha";
  List.iter (fun (s, options) ->
    add_project_dep pk s options
  ) (try get project_options "requires" with Not_found ->
    Printf.eprintf "No 'requires' for package %S\n%!" name;
    []
  )

let primitives = ref StringMap.empty
let add_primitive s f =
  let f env =
    try
      f env
    with e ->
      Printf.eprintf "Warning: exception raised while running primitive %S\n%!" s;
      raise e
  in
  primitives := StringMap.add s f !primitives

let rec translate_toplevel_statements pj config list =
  match list with
    [] -> config
  | stmt :: list ->
    let config = translate_toplevel_statement pj config stmt in
    translate_toplevel_statements pj config list

and translate_toplevel_statement pj config stmt =
  match stmt with
  | StmtDefineConfig (config_name, options) ->
    define_config config config_name options
  (*  (fun old_options -> translate_options old_options options); *)
  | StmtDefinePackage (package_type, library_name, simple_statements) ->
    begin
      let config = translate_statements pj config simple_statements in
      define_package pj library_name config package_type
    end;
    config
  | StmtBlock statements ->
    ignore (translate_toplevel_statements pj config statements);
    config
  | StmtIfThenElse (cond, ifthen, ifelse) -> begin
      if translate_condition config config.config_env cond then
        translate_toplevel_statements pj config ifthen
      else
        match ifelse with
          None -> config
        | Some ifelse ->
          translate_toplevel_statements pj config ifelse
    end
  | _ -> translate_simple_statement pj config stmt

and translate_statements pj config list =
  match list with
    [] -> config
  | stmt :: list ->
    let config = translate_statement pj config stmt in
    translate_statements pj config list

and translate_statement pj config stmt =
  match stmt with
  | StmtIfThenElse (cond, ifthen, ifelse) -> begin
      if translate_condition config config.config_env cond then
        translate_statements pj config ifthen
      else
        match ifelse with
          None -> config
        | Some ifelse ->
          translate_statements pj config ifelse
    end
  | _ -> translate_simple_statement pj config stmt

and translate_simple_statement pj config stmt =
  match stmt with
(*
    | StmtRequiresSet requirements ->
      { config with config_requires = requirements }
    | StmtRequiresAppend requirements ->
      { config with config_requires = config.config_requires @ requirements }
    | StmtFilesSet files ->
      { config with config_files = files }
    | StmtFilesAppend files ->
      { config with config_files = config.config_files @ files }
    | StmtTestsSet files ->
      { config with config_tests = files }
    | StmtTestsAppend files ->
      { config with config_tests = config.config_tests @ files }
*)
  | StmtOption option ->
    { config with config_env = translate_option config config.config_env option }
  (*    | StmtSyntax (syntax_name, camlpN, extensions) -> config *)
  | StmtIfThenElse _
  | StmtBlock _
  | StmtDefinePackage _
  | StmtDefineConfig _ -> assert false


and translate_condition config env cond =
  match cond with
  | IsEqual (exp1, exp2) ->
    let exp1 = translate_expression config env exp1 in
    let exp2 = translate_expression config env exp2 in
    exp1 = exp2

  | IsNonFalse exp ->
    let exp = try
      translate_expression config env exp
    with _ -> []
    in
    exp <> []

  | NotCondition cond -> not (translate_condition config env cond)
  | AndConditions (cond1, cond2) ->
    (translate_condition config env cond1) && (translate_condition config env cond2)
  | OrConditions (cond1, cond2) ->
    (translate_condition config env cond1) || (translate_condition config env cond2)

and translate_options config env list =
  match list with
    [] -> env
  | option :: list ->
    let env = translate_option config env option in
    translate_options config env list

and translate_option config env op =
  match op with
  | OptionConfigUse config_name ->
    translate_options config env (find_config config config_name)

  | OptionVariableSet (name, exp) ->

    (* TODO: global options *)
    let exp = translate_expression config env exp in
    let vars = try
      List.assoc name meta_options
    with Not_found -> [ name ]
    in
    List.fold_left (fun env name -> set env name exp) env vars

  | OptionVariableAppend (name, exp) ->
    (* TODO: global options *)

    let exp2 = translate_expression config env exp in

    let vars = try
      List.assoc name meta_options
    with Not_found -> [ name ]
    in
    List.fold_left (fun env name ->
      let exp1 = try get env name
      with Not_found ->
        Printf.eprintf "Variable %S is undefined (in +=)\n%!" name;
        exit 2
      in
      set env name (exp1 @ exp2)
    ) env vars

  | OptionIfThenElse (cond, ifthen, ifelse) ->
    begin
      if translate_condition config env cond then
        translate_option config env ifthen
      else
        match ifelse with
          None -> env
        | Some ifelse ->
          translate_option config env ifelse
    end
  | OptionBlock list -> translate_options config env list

and translate_expression config env exp =
  match exp with
    [] -> []
  | (ValueString s, args) :: tail ->
    (s, translate_options config env args) :: (translate_expression config env tail)
  | (ValuePrimitive s, args) :: tail ->
    let f = try StringMap.find s !primitives with
        Not_found ->
        failwith (Printf.sprintf "Could not find primitive %S\n%!" s)
    in
    (f (translate_options config env args)) @ (translate_expression config env tail)
  | (ValueVariable name, args) :: tail ->
    let exp = try get env name
    with Not_found ->
      failwith (Printf.sprintf "Variable %S is undefined\n%!" name)
    in
    (List.map (fun (v, env) ->
       v, translate_options config env args
    ) exp) @ (translate_expression config env tail)

let read_ocamlconf pj config filename =
  let ast = BuildOCPParse.read_ocamlconf filename in
  translate_toplevel_statements pj
    { config with
      config_dirname = Filename.dirname filename;
      config_filename = filename;
    } ast


let _ =
  add_primitive "subst_ext"
    (fun env ->
      let files = get_local env "files" in
      let from_ext = strings_of_plist (get_local env "from_ext") in
      let to_ext = strings_of_plist (get_local env "to_ext") in
      let to_ext = match to_ext with
          [ to_ext ] -> to_ext
        | _ -> failwith "%subst_ext: to_ext must specify only one extension"
      in
      let keep = try bool_of_plist (get_local env "keep_others") with _ -> false in
      let files = List.fold_left (fun files (file, env) ->
          try
            let pos = String.index file '.' in
            let ext = String.sub file pos (String.length file - pos) in
            if List.mem ext from_ext then
              let file = String.sub file 0 pos in
              (file ^ to_ext, env) :: files
            else raise Not_found
          with Not_found ->
            if keep then
              (file,env) :: files
            else files
        ) [] files in
      List.rev files

    )
