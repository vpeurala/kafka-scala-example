let cartesian l1 l2 =
  List.rev (
   List.fold_left
    (fun x a ->
      List.fold_left
       (fun y b ->
         (a, b)::y
       )
       x
       l2
   )
   []
   l1
 )
;;

let sums_to_2020 (a, b) = a + b == 2020;;

let sum_l l =
   let (r,_) = List.fold_left
      (fun (a_l, a_i) x -> ((a_i + x) :: a_l , a_i+x))
      ([],0) l in
   List.hd r;;

let product_l l =
   let (r,_) = List.fold_left
      (fun (a_l, a_i) x -> ((a_i * x) :: a_l , a_i * x))
      ([],1) l in
   List.hd r;;


let read_lines name : string list =
  let ic = open_in name in
  let try_read () =
    try Some (input_line ic) with End_of_file -> None in
  let rec loop acc = match try_read () with
    | Some s -> loop (s :: acc)
    | None -> close_in ic; List.rev acc in
  loop [];;







let lines = read_lines “input”;

let numbers = List.map int_of_string lines;;

let cartesians = cartesian numbers numbers;;

let pairs = List.filter sums_to_2020 cartesians;;

let (a, b) = List.hd pairs;;

let part1 = a * b;;

type 'a tuple = 'a list;;

let rec product'' (l:'a list tuple) =
    let rec aux ~acc l1 l2 = match l1, l2 with
    | [], _ | _, [] -> acc
    | h1::t1, h2::t2 ->
        let acc = (h1::h2)::acc in
        let acc = (aux ~acc t1 l2) in
        aux ~acc [h1] t2
    in match l with
    | [] -> []
    | [l1] -> List.map (fun x -> ([x]:'a tuple)) l1
    | l1::tl ->
        let tail_product = product'' tl in
        aux ~acc:[] l1 tail_product
;;

let triples = List.filter (fun l -> sum_l l == 2020) (product'' [numbers;numbers;numbers]);;

let part_2 = product_l (List.hd triples);;
