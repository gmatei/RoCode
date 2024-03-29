Require Import Strings.String.
Require Import Lists.List.
Local Open Scope string_scope. 
Local Open Scope list_scope.
Scheme Equality for string.
Scheme Equality for list.
Require Import ZArith.

Notation "[ ]" := nil (format "[ ]") : list_scope.
Notation "[ x ]" := (cons x nil) : list_scope.
Notation "[ x ; y ; .. ; z ]" := (cons x (cons y .. (cons z nil) ..)) : list_scope.


(* Constructor pentru numere naturale *)
Inductive TipNat :=
  | error_nat : TipNat
  | numar : nat -> TipNat.

(* Constructor pentru termeni de tip boolean *)
Inductive TipBool :=
  | error_bool : TipBool
  | boolean : bool -> TipBool.

Inductive TipString :=
  | error_string : TipString
  | sirchar : string -> TipString.

Inductive VectorNat :=
  | error_vector : VectorNat
  | vectornat: list TipNat -> VectorNat.

Coercion numar: nat >-> TipNat.
Coercion boolean: bool >-> TipBool.
(*Coercion vectornat: list >-> VectorNat.*)

(* Constructor pentru toate tipurile posibile ale unei variabile*)
Inductive Rezultat :=
  | nondecl : Rezultat
  | noninit : Rezultat
  | default : Rezultat
  | rez_nat : TipNat -> Rezultat
  | rez_bool : TipBool -> Rezultat
  | rez_string : TipString -> Rezultat
  | rez_vector : VectorNat -> Rezultat.

(*Scheme Equality for Rezultat.*)

(*Variabilele vor fi de tip string, initial fiind nedeclarate*)
Definition Env := string -> Rezultat.
Definition env : Env := fun x => nondecl.

Compute (env "x").

(*
(*Functie care verifica daca doi termeni au acelasi tip*)

Definition check_type_eq (t1 : Rezultat) (t2 : Rezultat) : bool :=
  match t1 with
    | nondecl => match t2 with 
                     | nondecl => true
                     | _ => false
                     end
    | noninit => match t2 with 
                     | noninit => true
                     | _ => false
                     end
    | default => match t2 with 
                     | default => true
                     | _ => false
                     end
    | rez_nat t1 => match t2 with 
                     | rez_nat t1 => true
                     | _ => false
                     end
    | rez_bool t1 => match t2 with 
                     | rez_bool t1 => true
                     | _ => false
                     end
    | rez_string t1 => match t2 with 
                     | rez_string t1 => true
                     | _ => false
                     end
  end.


Compute (check_type_eq (rez_nat 3) (rez_nat 5)). (* true *)
Compute (check_type_eq noninit (rez_nat 17)). (* false *)
Compute (check_type_eq (rez_bool false) (rez_bool true)). (* true *) *)

Definition update (env : Env) (x : string) (v : Rezultat) : Env :=
  fun y =>
    (*if (andb (eqb x y ) (check_type_eq (env x) (env y))) *)
    if (eqb x y)
    then v
    else (env y).

(*Notation "S [ V /' X ]" := (update S X V) (at level 0).*)

Compute (env "y").
Compute (update (update env "y" (default)) "y" (rez_nat 3) "y").
Compute ((update (update (update env "y" default) "y" (rez_nat 10)) "y" (rez_bool true)) "y").


(* Sintaxa aritmetica *)

Inductive AExp :=
| avar: string -> AExp 
| anum: TipNat -> AExp
| aplus: AExp -> AExp -> AExp
| asub: AExp -> AExp -> AExp
| amul: AExp -> AExp -> AExp 
| adiv: AExp -> AExp -> AExp 
| amod: AExp -> AExp -> AExp
| apower: AExp -> AExp -> AExp
| amin: AExp -> AExp -> AExp
| amax: AExp -> AExp -> AExp.

Coercion anum: TipNat >-> AExp.
Coercion avar: string >-> AExp.

(* Notatii operatii aritmetice *)
Notation "A +' B" := (aplus A B)(at level 50, left associativity).
Notation "A -' B" := (asub A B)(at level 50, left associativity).
Notation "A *' B" := (amul A B)(at level 48, left associativity).
Notation "A /' B" := (adiv A B)(at level 48, left associativity).
Notation "A %' B" := (amod A B)(at level 45, left associativity).
Notation "A ^' B" := (apower A B)(at level 44, left associativity).
Notation "A <?> B" := (amin A B)(at level 55, left associativity).
Notation "A >?< B" := (amax A B)(at level 55, left associativity).

Definition plus_TipNat (n1 n2 : TipNat) : TipNat :=
  match n1, n2 with
    | error_nat, _ => error_nat
    | _, error_nat => error_nat
    | numar v1, numar v2 => numar (v1 + v2)
    end.

Definition sub_TipNat (n1 n2 : TipNat) : TipNat :=
  match n1, n2 with
    | error_nat, _ => error_nat
    | _, error_nat => error_nat
    | numar v1, numar v2 => if Nat.ltb v1 v2
                        then error_nat
                        else numar (v1 - v2)
    end.

Definition mul_TipNat (n1 n2 : TipNat) : TipNat :=
  match n1, n2 with
    | error_nat, _ => error_nat
    | _, error_nat => error_nat
    | numar v1, numar v2 => numar (v1 * v2)
    end.

Definition div_TipNat (n1 n2 : TipNat) : TipNat :=
  match n1, n2 with
    | error_nat, _ => error_nat
    | _, error_nat => error_nat
    | _, numar 0 => error_nat
    | numar v1, numar v2 => numar (Nat.div v1 v2)
    end.

Definition mod_TipNat (n1 n2 : TipNat) : TipNat :=
  match n1, n2 with
    | error_nat, _ => error_nat
    | _, error_nat => error_nat
    | _, numar 0 => error_nat
    | numar v1, numar v2 => numar (v1 - v2 * (Nat.div v1 v2))
    end.

Definition power_TipNat (n1 n2 : TipNat) : TipNat :=
  match n1, n2 with
    | error_nat, _ => error_nat
    | _, error_nat => error_nat
    | numar v1, numar v2 => numar (v1 ^ v2) 
    end.

Definition max_TipNat (n1 n2 : TipNat) : TipNat :=
  match n1, n2 with
    | error_nat, _ => error_nat
    | _, error_nat => error_nat
    | numar v1, numar v2 => numar (max v1 v2) 
    end.

Definition min_TipNat (n1 n2 : TipNat) : TipNat :=
  match n1, n2 with
    | error_nat, _ => error_nat
    | _, error_nat => error_nat
    | numar v1, numar v2 => numar (min v1 v2) 
    end.

(* Semantica recursiva pentru operatii aritmetice *)

Fixpoint aeval_r (a : AExp) (env : Env) : TipNat :=
  match a with
  | avar v => match (env v) with
                | rez_nat n => n
                | _ => error_nat
                end
  | anum v => v
  | aplus a1 a2 => (plus_TipNat (aeval_r a1 env) (aeval_r a2 env))
  | amul a1 a2 => (mul_TipNat (aeval_r a1 env) (aeval_r a2 env))
  | asub a1 a2 => (sub_TipNat (aeval_r a1 env) (aeval_r a2 env))
  | adiv a1 a2 => (div_TipNat  (aeval_r a1 env) (aeval_r a2 env))
  | amod a1 a2 => (mod_TipNat (aeval_r a1 env) (aeval_r a2 env))
  | apower a1 a2 => (power_TipNat (aeval_r a1 env) (aeval_r a2 env))
  | amin a1 a2 => (min_TipNat (aeval_r a1 env) (aeval_r a2 env))
  | amax a1 a2 => (max_TipNat (aeval_r a1 env) (aeval_r a2 env))
  end.

(* Semantica Big-Step pentru operatii artimetice *)

Reserved Notation "A =[ S ]=> N" (at level 60).
Inductive aeval : AExp -> Env -> TipNat -> Prop :=
| const : forall n sigma, anum n =[ sigma ]=> n
| var : forall v sigma, avar v =[ sigma ]=>  match (sigma v) with
                                              | rez_nat x => x
                                              | _ => error_nat
                                              end
| add : forall a1 a2 i1 i2 sigma n,
    a1 =[ sigma ]=> i1 ->
    a2 =[ sigma ]=> i2 ->
    n = (plus_TipNat i1 i2) ->
    a1 +' a2 =[sigma]=> n
| times : forall a1 a2 i1 i2 sigma n,
    a1 =[ sigma ]=> i1 ->
    a2 =[ sigma ]=> i2 ->
    n = (mul_TipNat i1 i2) ->
    a1 *' a2 =[sigma]=> n
| minus : forall a1 a2 i1 i2 sigma n,
    a1 =[ sigma ]=> i1 ->
    a2 =[ sigma ]=> i2 ->
    n = (sub_TipNat i1 i2) ->
    a1 -' a2 =[sigma]=> n
| division : forall a1 a2 i1 i2 sigma n,
    a1 =[ sigma ]=> i1 ->
    a2 =[ sigma ]=> i2 ->
    n = (div_TipNat  i1 i2) ->
    a1 /' a2 =[sigma]=> n
| modulo : forall a1 a2 i1 i2 sigma n,
    a1 =[ sigma ]=> i1 ->
    a2 =[ sigma ]=> i2 ->
    n = (mod_TipNat i1 i2) ->
    a1 %' a2 =[sigma]=> n
| power : forall a1 a2 i1 i2 sigma n,
    a1 =[ sigma ]=> i1 ->
    a2 =[ sigma ]=> i2 ->
    n = (power_TipNat i1 i2) ->
    a1 ^' a2 =[sigma]=> n
| minimum : forall a1 a2 i1 i2 sigma n,
    a1 =[ sigma ]=> i1 ->
    a2 =[ sigma ]=> i2 ->
    n = (power_TipNat i1 i2) ->
    a1 <?> a2 =[sigma]=> n
| maximum : forall a1 a2 i1 i2 sigma n,
    a1 =[ sigma ]=> i1 ->
    a2 =[ sigma ]=> i2 ->
    n = (power_TipNat i1 i2) ->
    a1 >?< a2 =[sigma]=> n
where "a =[ sigma ]=> n" := (aeval a sigma n).

Example minus_error : 1 -' 5 =[ env ]=> error_nat.
Proof.
  eapply minus.
  - apply const.
  - apply const.
  - simpl. reflexivity.
Qed.

Example division_error : 3 /' 0 =[ env ]=> error_nat.
Proof.
  eapply division.
  - apply const.
  - apply const.
  - simpl. reflexivity.
Qed.

Example modulo_error : 3 %' 0 =[ env ]=> error_nat.
Proof.
  eapply modulo.
  - apply const.
  - apply const.
  - simpl. reflexivity.
Qed.

(* Sintaxa vectori nat*)
Inductive VExp :=
| vvar: string -> VExp 
| vect: VectorNat -> VExp
| vectlist: list TipNat -> VExp
| vnum: TipNat -> VExp
| plus: VExp -> VExp -> VExp (*concatenare*)
| nth_elem: AExp -> VExp -> VExp (*returneaza al n-lea element al vectorului*)
| headv: VExp -> VExp
| tailv: VExp -> VExp
| vlength: VExp -> VExp
| reverse: VExp -> VExp
| extractn: AExp -> VExp -> VExp. (*returneaza primele n elemente ale vectorului*)

Coercion vect: VectorNat >-> VExp.
Coercion vvar: string >-> VExp.

(* Notatii vectori *)
Notation "A |+| B" := (plus A B)(at level 50, left associativity).
Notation "'Elementul' A 'din' B" := (nth_elem A B)(at level 50, left associativity).
Notation "'h(' A ')'" := (headv A)(at level 50, left associativity).
Notation "'t(' A ')'" := (tailv A)(at level 50, left associativity).
Notation "'lungimelist' A" := (vlength A)(at level 50, left associativity).
Notation "'invers' A" := (reverse A)(at level 50, left associativity).
Notation "'Primele' A 'elemente' B" := (extractn A B)(at level 50, left associativity).

Definition plusV (n1 n2 : VectorNat) : VectorNat :=
  match n1, n2 with
    | error_vector, _ => error_vector
    | _, error_vector => error_vector
    | vectornat v1, vectornat v2 => vectornat (v1 ++ v2)
    end.

Definition lengthV (n1 : VectorNat) : VectorNat :=
  match n1 with
    | error_vector => error_vector
    | vectornat v1 => vectornat [numar (length v1)]
    end. 

Definition extractnV (n : TipNat) (n1: VectorNat) : VectorNat :=
  match n, n1 with
    | _, error_vector => error_vector
    | error_nat, _ => error_vector
    | numar v, vectornat v1 => vectornat (firstn v v1)
    end.

Definition reverseV (n1 : VectorNat) : VectorNat :=
  match n1 with
    | error_vector => error_vector
    | vectornat v1 => vectornat (rev v1)
    end.

Definition tailV (n1 : VectorNat) : VectorNat :=
  match n1 with
    | error_vector => error_vector
    | vectornat v1 => vectornat (v1)
    end.

Definition headV (n1 : VectorNat) : VectorNat :=
  match n1 with
    | error_vector => error_vector
    | vectornat v1 => vectornat [hd error_nat v1]
    end.


Definition nthelem (n:TipNat) (n1 : VectorNat) : VectorNat :=
  match n, n1 with
    | _, error_vector => error_vector
    | error_nat, _ => error_vector
    | numar v, vectornat v1 => vectornat [nth v v1 error_nat]
    end.

(* Semantica recursiva pentru vectori nat *)

Fixpoint veval_r (a : VExp) (env : Env) : VectorNat :=
  match a with
  | vvar v => match (env v) with
                | rez_vector n => n
                | _ => error_vector
                end
  | vect v => v
  | vectlist v => vectornat v
  | vnum v => vectornat [v]
  | plus a1 a2 => (plusV (veval_r a1 env) (veval_r a2 env))
  | nth_elem a1 a2 => (nthelem (aeval_r a1 env) (veval_r a2 env))
  | headv a1 => (headV (veval_r a1 env))
  | tailv a1 => (tailV  (veval_r a1 env))
  | vlength a1 => (lengthV (veval_r a1 env))
  | reverse a1 => (reverseV (veval_r a1 env))
  | extractn a1 a2 => (extractnV (aeval_r a1 env) (veval_r a2 env))
  end.

(* Semantica Big-Step pentru vectori nat *)

Reserved Notation "A =\ S \=> N" (at level 60).
Inductive veval : VExp -> Env -> VectorNat -> Prop :=
| constv : forall n sigma, vect n =\ sigma \=> n
| varv : forall v sigma, vvar v =\ sigma \=>  match (sigma v) with
                                              | rez_vector x => x
                                              | _ => error_vector
                                              end
| vectlistv : forall n sigma, vectlist n =\ sigma \=> vectornat n
| vnumv : forall n sigma, vnum n =\ sigma \=> vectornat [n]
| addv : forall a1 a2 i1 i2 sigma n,
    a1 =\ sigma \=> i1 ->
    a2 =\ sigma \=> i2 ->
    n = (plusV i1 i2) ->
    a1 |+| a2 =\sigma\=> n
| nth_elemv : forall a1 a2 i1 i2 sigma n,
    a1 =[ sigma ]=> i1 ->
    a2 =\ sigma \=> i2 ->
    n = (nthelem i1 i2) ->
    Elementul a1 din a2 =\sigma\=> n
| headvv : forall a1 i1 sigma n,
    a1 =\ sigma \=> i1 ->
    n = (headV i1) ->
    h( a1 ) =\sigma\=> n
| tailvv : forall a1 i1 sigma n,
    a1 =\ sigma \=> i1 ->
    n = (headV i1) ->
    t( a1 ) =\sigma\=> n
| lengthv : forall a1 i1 sigma n,
    a1 =\ sigma \=> i1 ->
    n = (lengthV i1) ->
    lungimelist a1 =\sigma\=> n
| reversev : forall a1 i1 sigma n,
    a1 =\ sigma \=> i1 ->
    n = (lengthV i1) ->
    invers a1 =\sigma\=> n
| extractnvv : forall a1 a2 i1 i2 sigma n,
    a1 =[ sigma ]=> i1 ->
    a2 =\ sigma \=> i2 ->
    n = (extractnV i1 i2) ->
    Primele a1 elemente a2 =\sigma\=> n
where "a =\ sigma \=> n" := (veval a sigma n).

(* Sintaxa booleana *)

Inductive BExp :=
| berror
| btrue
| bfalse
| bvar: string -> BExp
| beqn : AExp -> AExp -> BExp
| beqb : BExp -> BExp -> BExp
| blt : AExp -> AExp -> BExp
| blte : AExp -> AExp -> BExp
| bgt : AExp -> AExp -> BExp
| bgte : AExp -> AExp -> BExp
| bnot : BExp -> BExp
| band : BExp -> BExp -> BExp
| bor : BExp -> BExp -> BExp
| bxor : BExp -> BExp -> BExp
| bimply : BExp -> BExp -> BExp.

Coercion bvar: string >-> BExp.

(* Notatii pentru operatii boolene *)
Notation "A <' B" := (blt A B) (at level 70).
Notation "A <e' B" := (blte A B) (at level 70).
Notation "A >' B" := (bgt A B) (at level 70).
Notation "A >e' B" := (bgte A B) (at level 70).
Notation "!' A" := (bnot A)(at level 51, left associativity).
Notation "A &&' B" := (band A B)(at level 52, left associativity).
Notation "A ==n B" := (beqn A B)(at level 52, left associativity).
Notation "A ==b B" := (beqb A B)(at level 52, left associativity).
Notation "A ||' B" := (bor A B)(at level 53, left associativity).
Notation "A ->' B" := (bimply A B)(at level 53, left associativity).
Notation "A ~XOR~ B" := (bxor A B)(at level 53, left associativity).

Definition eqn_TipBool (n1 n2 : TipNat) : TipBool :=
  match n1, n2 with
    | error_nat, _ => error_bool
    | _, error_nat => error_bool
    | numar v1, numar v2 => boolean (Nat.eqb v1 v2)
    end.

Definition eqb_TipBool (n1 n2 : TipBool) : TipBool :=
  match n1, n2 with
    | error_bool, _ => error_bool
    | _, error_bool => error_bool
    | boolean v1, boolean v2 => Bool.eqb v1 v2
    end.

Definition lt_TipBool (n1 n2 : TipNat) : TipBool :=
  match n1, n2 with
    | error_nat, _ => error_bool
    | _, error_nat => error_bool
    | numar v1, numar v2 => boolean (Nat.ltb v1 v2)
    end.

Definition lte_TipBool (n1 n2 : TipNat) : TipBool :=
  match n1, n2 with
    | error_nat, _ => error_bool
    | _, error_nat => error_bool
    | numar v1, numar v2 => boolean (Nat.leb v1 v2)
    end.

Definition gt_TipBool (n1 n2 : TipNat) : TipBool :=
  match n1, n2 with
    | error_nat, _ => error_bool
    | _, error_nat => error_bool
    | numar v1, numar v2 => boolean (Nat.ltb v2 v1)
    end.

Definition gte_TipBool (n1 n2 : TipNat) : TipBool :=
  match n1, n2 with
    | error_nat, _ => error_bool
    | _, error_nat => error_bool
    | numar v1, numar v2 => boolean (Nat.leb v2 v1)
    end.

Definition not_TipBool (n :TipBool) : TipBool :=
  match n with
    | error_bool => error_bool
    | boolean v => negb v
    end.

Definition and_TipBool (n1 n2 : TipBool) : TipBool :=
  match n1, n2 with
    | error_bool, _ => error_bool
    | _, error_bool => error_bool
    | boolean v1, boolean v2 => andb v1 v2
    end.

Definition or_TipBool (n1 n2 : TipBool) : TipBool :=
  match n1, n2 with
    | error_bool, _ => error_bool
    | _, error_bool => error_bool
    | boolean v1, boolean v2 => orb v1 v2
    end.

Definition imply_TipBool (n1 n2 : TipBool) : TipBool :=
  match n1, n2 with
    | error_bool, _ => error_bool
    | _, error_bool => error_bool
    | boolean v1, boolean v2 => implb v1 v2
    end.

Definition xor_TipBool (n1 n2 : TipBool) : TipBool :=
  match n1, n2 with
    | error_bool, _ => error_bool
    | _, error_bool => error_bool
    | boolean v1, boolean v2 => xorb v1 v2
    end.

(* Semantica recursiva pentru operatii boolene *)

Fixpoint beval_r (a : BExp) (envnat : Env) : TipBool :=
  match a with
  | btrue => true
  | bfalse => false
  | berror => error_bool
  | bvar v => match (env v) with
               | rez_bool n => n
               | _ => error_bool
               end
  | beqn a1 a2 => (eqn_TipBool (aeval_r a1 envnat) (aeval_r a2 envnat))
  | beqb a1 a2 => (eqb_TipBool (beval_r a1 envnat) (beval_r a2 envnat))
  | blt a1 a2 => (lt_TipBool (aeval_r a1 envnat) (aeval_r a2 envnat))
  | blte a1 a2 => (lte_TipBool (aeval_r a1 envnat) (aeval_r a2 envnat))
  | bgt a1 a2 => (gt_TipBool (aeval_r a1 envnat) (aeval_r a2 envnat))
  | bgte a1 a2 => (gte_TipBool (aeval_r a1 envnat) (aeval_r a2 envnat))
  | bnot b1 => (not_TipBool (beval_r b1 envnat))
  | band b1 b2 => (and_TipBool (beval_r b1 envnat) (beval_r b2 envnat))
  | bor b1 b2 => (or_TipBool (beval_r b1 envnat) (beval_r b2 envnat))
  | bimply b1 b2 => (imply_TipBool (beval_r b1 envnat) (beval_r b2 envnat))
  | bxor b1 b2 => (xor_TipBool (beval_r b1 envnat) (beval_r b2 envnat))
  end.

(* Semantica Big-Step pentru operatii boolene *)

Reserved Notation "B ={ S }=> B'" (at level 70).
Inductive beval : BExp -> Env -> TipBool -> Prop :=
| b_error: forall sigma, berror  ={ sigma }=> error_bool
| b_true : forall sigma, btrue ={ sigma }=> true
| b_false : forall sigma, bfalse ={ sigma }=> false
| b_var : forall v sigma, bvar v ={ sigma }=>  match (sigma v) with
                                                | rez_bool x => x
                                                | _ => error_bool
                                                end
| b_equalnat : forall a1 a2 i1 i2 sigma b,
    a1 =[ sigma ]=> i1 ->
    a2 =[ sigma ]=> i2 ->
    b = (eqn_TipBool i1 i2) ->
    a1 ==n a2 ={ sigma }=> b
| b_lessthan : forall a1 a2 i1 i2 sigma b,
    a1 =[ sigma ]=> i1 ->
    a2 =[ sigma ]=> i2 ->
    b = (lt_TipBool i1 i2) ->
    a1 <' a2 ={ sigma }=> b
| b_lessorequalthan : forall a1 a2 i1 i2 sigma b,
    a1 =[ sigma ]=> i1 ->
    a2 =[ sigma ]=> i2 ->
    b = (lte_TipBool i1 i2) ->
    a1 <e' a2 ={ sigma }=> b
| b_greaterthan : forall a1 a2 i1 i2 sigma b,
    a1 =[ sigma ]=> i1 ->
    a2 =[ sigma ]=> i2 ->
    b = (gt_TipBool i1 i2) ->
    a1 >' a2 ={ sigma }=> b
| b_greaterorequalthan : forall a1 a2 i1 i2 sigma b,
    a1 =[ sigma ]=> i1 ->
    a2 =[ sigma ]=> i2 ->
    b = (gte_TipBool i1 i2) ->
    a1 >e' a2 ={ sigma }=> b
| b_not : forall a1 i1 sigma b,
    a1 ={ sigma }=> i1 ->
    b = (not_TipBool i1) ->
    !'a1 ={ sigma }=> b
| b_and : forall a1 a2 i1 i2 sigma b,
    a1 ={ sigma }=> i1 ->
    a2 ={ sigma }=> i2 ->
    b = (and_TipBool i1 i2) ->
    (a1 &&' a2) ={ sigma }=> b 
| b_or : forall a1 a2 i1 i2 sigma b,
    a1 ={ sigma }=> i1 ->
    a2 ={ sigma }=> i2 ->
    b = (or_TipBool i1 i2) ->
    (a1 ||' a2) ={ sigma }=> b 
| b_xor : forall a1 a2 i1 i2 sigma b,
    a1 ={ sigma }=> i1 ->
    a2 ={ sigma }=> i2 ->
    b = (xor_TipBool i1 i2) ->
    (a1 ~XOR~ a2) ={ sigma }=> b 
| b_equalbool : forall a1 a2 i1 i2 sigma b,
    a1 ={ sigma }=> i1 ->
    a2 ={ sigma }=> i2 ->
    b = (eqb_TipBool i1 i2) ->
    a1 ==b a2 ={ sigma }=> b 
| b_imply : forall a1 a2 i1 i2 sigma b,
    a1 ={ sigma }=> i1 ->
    a2 ={ sigma }=> i2 ->
    b = (imply_TipBool i1 i2) ->
    (a1 ->' a2) ={ sigma }=> b 
where "B ={ S }=> B'" := (beval B S B').

(* Because "n" is not declared *)
Example boolean_operation : bnot (100 <' "n") ={ env }=> error_bool.
Proof.
  eapply b_not.
  eapply b_lessthan.
  - eapply const.
  - eapply var.
  - simpl. reflexivity.
  - simpl. reflexivity.
Qed.


Require Import Ascii.
(* Sintaxa siruri de caractere *)
Inductive CExp :=
| cvar: string -> CExp 
| csir: TipString -> CExp
| cnum: AExp -> CExp
(*| char: (option ascii) -> CExp*)
| concat: CExp -> CExp -> CExp
| clength: CExp -> CExp
(*| nth_char: CExp -> AExp -> CExp*)
| substringNM: CExp -> AExp -> AExp -> CExp.

Coercion csir: TipString >-> CExp.
Coercion cvar: string >-> CExp.


(* Notatii operatii siruri de caractere *)
Notation "A +&+ B" := (concat A B)(at level 50, left associativity).
(*Notation "A 'caracterul' B" := (nth_char A B)(at level 50, left associativity).*)
Notation "A 'incepand' B 'lungime' C" := (substringNM A B C)(at level 50, left associativity).
Notation "'lungimesir' A" := (clength A)(at level 50, left associativity).


(*
Definition char_TipString (n1 : (option ascii)) : TipString :=
  match n1 with
    | error_string => error_string
    | sirchar v1 => sirchar v1
    end.*)

(*
Definition nth_char_TipString (n1 : TipString) (n2 : TipNat) : CExp :=
  match n1, n2 with
    | error_string, _ => error_string
    | sirchar v1, error_nat => error_string
    | sirchar v1, numar v2 => sirchar (string_of_list_ascii(get v2 v1))
    end.*)

Fixpoint lengths (s : string) : nat :=
  match s with
  | EmptyString => 0
  | String c s' => S (lengths s')
  end.

Definition length_TipString (n1 : TipString) : TipString :=
  match n1 with
    | error_string => error_string
    | sirchar v1 => sirchar ("numar (lengths v1)")
    end.

Definition concat_TipString (n1 n2 : TipString) : TipString :=
  match n1, n2 with
    | error_string, _ => error_string
    | _, error_string => error_string
    | sirchar v1, sirchar v2 => sirchar (v1 ++ v2)
    end.

Definition substringNM_TipString (n1 : TipString) (N M : TipNat) : TipString :=
  match n1, N, M with
    | error_string, _, _ => error_string
    | _, error_nat, _ => error_string
    | _, _, error_nat => error_string
    | sirchar v1, numar N, numar M => sirchar (substring N M v1)
    end.

(* Semantica recursiva pentru siruri de caractere *)

Fixpoint ceval_r (a : CExp) (env : Env) : TipString :=
  match a with
  | cvar v => match (env v) with
                | rez_string n => n
                | _ => error_string
                end
  | cnum v => sirchar "v"
  | csir v => v
  | concat a1 a2 => (concat_TipString (ceval_r a1 env) (ceval_r a2 env))
  | clength a1=> (length_TipString (ceval_r a1 env))
  | substringNM a1 a2 a3 => (substringNM_TipString (ceval_r a1 env) (aeval_r a2 env) (aeval_r a3 env))
  end.

(* Semantica Big-Step pentru siruri de caractere *)

Reserved Notation "A =/ S /=> N" (at level 60).
Inductive ceval : CExp -> Env -> TipString -> Prop :=
| consts : forall n sigma, csir n =/ sigma /=> n
| vars : forall v sigma, cvar v =/ sigma /=>  match (sigma v) with
                                              | rez_string x => x
                                              | _ => error_string
                                              end
| csirc : forall n sigma, cnum n =/ sigma /=> sirchar "n"
| concatv : forall a1 a2 i1 i2 sigma n,
    a1 =/ sigma /=> i1 ->
    a2 =/ sigma /=> i2 ->
    n = ( concat_TipString i1 i2) ->
    a1 +&+ a2 =/sigma/=> n
| clengthv : forall a1 i1 sigma n,
    a1 =/ sigma /=> i1 ->
    n = (length_TipString i1) ->
    lungimesir a1 =/sigma/=> n
| substringNMv : forall a1 a2 a3 i1 i2 i3 sigma n,
    a1 =/ sigma /=> i1 ->
    a2 =[ sigma ]=> i2 ->
    a3 =[ sigma ]=> i3 ->
    n = (substringNM_TipString i1 i2 i3) ->
    a1 incepand a2 lungime a3 =/sigma/=> n
where "a =/ sigma /=> n" := (ceval a sigma n).


(* Sintaxa pentru statements *)
Inductive Stmt :=
  | nat_decl: string -> AExp -> Stmt 
  | bool_decl: string -> BExp -> Stmt 
  | char_decl: string -> CExp -> Stmt 
  | vect_decl: string -> VExp -> Stmt 
  | nat_assign : string -> AExp -> Stmt
  | bool_assign : string -> BExp -> Stmt 
  | char_assign : string -> CExp -> Stmt 
  | vect_assign : string -> VExp -> Stmt 
  | sequence : Stmt -> Stmt -> Stmt
  | while : BExp -> Stmt -> Stmt
  | ifthenelse : BExp -> Stmt -> Stmt -> Stmt
  | ifthen : BExp -> Stmt -> Stmt
  | myswitch : AExp -> VExp -> list Stmt -> Stmt
  | skip : Stmt -> Stmt -> Stmt.


Notation "X :n= A" := (nat_assign X A)(at level 90).
Notation "X :b= A" := (bool_assign X A)(at level 90).
Notation "X :s= A" := (char_assign X A)(at level 90).
Notation "X :l= A" := (vect_assign X A)(at level 90).
Notation "'iNat' X ::= A" := (nat_decl X A)(at level 90).
Notation "'iBool' X ::= A" := (bool_decl X A)(at level 90).
Notation "'iSir' X ::= A" := (char_decl X A)(at level 90).
Notation "'iList' X ::= A" := (vect_decl X A)(at level 90).
Notation "S1 ;; S2" := (sequence S1 S2) (at level 93, right associativity).
Notation " 'daca' ( A ) 'atunci' { B }" := (ifthen A B) (at level 97).
Notation " 'daca' ( A ) 'atunci' { B } 'altfel' { C }" := (ifthenelse A B C) (at level 97).
Notation " A 'atunci' B 'altfel' C " := (ifthenelse A B C) (at level 97).
Notation "'cat_timp' ( A ) { B }" := (while A B) (at level 97).
Notation "'pentru' ( A # B # C ) { S }" := (A ;; while B ( S ;; C )) (at level 97).
Notation "'sari_peste' A 'incepe' B" := (skip A B) (at level 97).
Notation "'input' X :>: A " := (vect_decl X A) (at level 97).
Notation "'output' X :<: A " := (vect_decl X A) (at level 97).
Notation "'testeaza' ( B ) 'cazurile' ( L1 ) 'optiunile' ( L2 )" := (myswitch B L1 L2) (at level 97).

(* Semantica tip Big-Step pentru statements *)
Reserved Notation "S -{ Sigma }-> Sigma'" (at level 60).
Inductive eval : Stmt -> Env -> Env -> Prop :=
| e_nat_decl: forall a i x sigma sigma',
   a =[ sigma ]=> i ->
   sigma' = (update sigma x (rez_nat i)) ->
   (iNat x ::= a) -{ sigma }-> sigma'
| e_nat_assign: forall a i x sigma sigma',
    a =[ sigma ]=> i ->
    sigma' = (update sigma x (rez_nat i)) ->
    (x :n= a) -{ sigma }-> sigma'
| e_bool_decl: forall a i x sigma sigma',
   a ={ sigma }=> i ->
   sigma' = (update sigma x (rez_bool i)) ->
   (iBool x ::= a) -{ sigma }-> sigma'
| e_bool_assign: forall a i x sigma sigma',
    a ={ sigma }=> i ->
    sigma' = (update sigma x (rez_bool i)) ->
    (x :b= a) -{ sigma }-> sigma'
| e_char_decl: forall a i x sigma sigma',
   a =/ sigma /=> i ->
   sigma' = (update sigma x (rez_string i)) ->
   (iSir x ::= a) -{ sigma }-> sigma'
| e_char_assign: forall a i x sigma sigma',
    a =/ sigma /=> i ->
    sigma' = (update sigma x (rez_string i)) ->
    (x :s= a) -{ sigma }-> sigma'
| e_string_decl: forall a i x sigma sigma',
   a =\ sigma \=> i ->
   sigma' = (update sigma x (rez_vector i)) ->
   (iList x ::= a) -{ sigma }-> sigma'
| e_string_assign: forall a i x sigma sigma',
    a =\ sigma \=> i ->
    sigma' = (update sigma x (rez_vector i)) ->
    (x :l= a) -{ sigma }-> sigma'
| e_seq : forall s1 s2 sigma sigma1 sigma2,
    s1 -{ sigma }-> sigma1 ->
    s2 -{ sigma1 }-> sigma2 ->
    (s1 ;; s2) -{ sigma }-> sigma2
| e_if_then : forall b s sigma,
    ifthen b s -{ sigma }-> sigma
| e_if_then_elsetrue : forall b s1 s2 sigma sigma',
    b ={ sigma }=> true ->
    s1 -{ sigma }-> sigma' ->
    ifthenelse b s1 s2 -{ sigma }-> sigma' 
| e_if_then_elsefalse : forall b s1 s2 sigma sigma',
    b ={ sigma }=> false ->
    s2 -{ sigma }-> sigma' ->
    ifthenelse b s1 s2 -{ sigma }-> sigma' 
| e_whilefalse : forall b s sigma,
    b ={ sigma }=> false ->
    while b s -{ sigma }-> sigma
| e_whiletrue : forall b s sigma sigma',
    b ={ sigma }=> true ->
    (s ;; while b s) -{ sigma }-> sigma' ->
    while b s -{ sigma }-> sigma'
| e_skip : forall s1 s2 sigma sigma2,
    s2 -{ sigma }-> sigma2 ->
    skip s1 s2 -{ sigma }-> sigma2
where "s -{ sigma }-> sigma'" := (eval s sigma sigma').

(* Semantica recursiva pentru statements *)

Fixpoint eval_r (s : Stmt) (env : Env) (gas: nat) : Env :=
    match gas with
    | 0 => env
    | S gas' => match s with
                | sequence S1 S2 => eval_r S2 (eval_r S1 env gas') gas'
                | nat_decl a aexp => update (update env a default) a (rez_nat (aeval_r aexp env))
                | bool_decl b bexp => update (update env b default) b (rez_bool (beval_r bexp env))
                | char_decl c cexp => update (update env c default) c (rez_string (ceval_r cexp env))
                | vect_decl v vexp => update (update env v default) v (rez_vector (veval_r vexp env))
                | nat_assign a aexp => update env a (rez_nat (aeval_r aexp env))
                | bool_assign b bexp => update env b (rez_bool (beval_r bexp env))
                | char_assign c cexp => update env c (rez_string (ceval_r cexp env))
                | vect_assign v vexp => update env v (rez_vector (veval_r vexp env))
                | ifthen cond s' => 
                    match (beval_r cond env) with
                    | error_bool => env
                    | boolean v => match v with
                                 | true => eval_r s' env gas'
                                 | false => env
                                 end
                    end
                | ifthenelse cond S1 S2 => 
                    match (beval_r cond env) with
                        | error_bool => env
                        | boolean v  => match v with
                                 | true => eval_r S1 env gas'
                                 | false => eval_r S2 env gas'
                                 end
                         end
                | while cond s' => 
                    match (beval_r cond env) with
                        | error_bool => env
                        | boolean v => match v with
                                     | true => eval_r (s' ;; (while cond s')) env gas'
                                     | false => env
                                     end
                        end
                | myswitch a L1 L2 => match (aeval_r a env) with
                                      | _ => eval_r (myswitch a (h( L1 )) ( L2 ))    env gas' 
                                      end            
                | skip a b => eval_r b env gas'                
                end
    end.

(*Exemple functionalitate*)

Definition while_stmt :=
    iNat "i" ::= 0 ;;
    iNat "sum" ::= 0 ;;
    (cat_timp 
        ("i" <' 6) 
        {
           "sum" :n= "sum" +' "i" ;;
           "i" :n= "i" +' 1
        });;

     iNat "i2" ::= 0 ;;
     (daca ( "i" ==n 0 )
        atunci { "i2" :n= 3 }
        altfel { "i2" :n= 4 });;

    iNat "i3" ::= "i2" ^' 2 ;;
    iNat "i4" ::= "i2" %' 3 ;;
    iNat "i5" ::= "i2" <?> 2 ;;
    iNat "i6" ::= "i2" >?< 2 
    .

Compute (eval_r while_stmt env 100) "i".
Compute (eval_r while_stmt env 100) "sum".
Compute (eval_r while_stmt env 100) "i2".
Compute (eval_r while_stmt env 100) "i3".
Compute (eval_r while_stmt env 100) "i4".
Compute (eval_r while_stmt env 100) "i5".
Compute (eval_r while_stmt env 100) "i6".

Definition for_stmt :=
    iNat "sum" ::= 0 ;;
    pentru ( iNat "i" ::= 0 # "i" <e' 6 # "i" :n= "i" +' 1 ) {
      "sum" :n= "sum" +' "i"
    }.

Compute (eval_r for_stmt env 100) "sum".

Definition example :=
    iNat "sum" ::= 1 ;;

    iSir "S1" ::= "sirul1" ;; 
    iSir "S2" ::= "sirul2" ;; 
    
    iSir "S3" ::= "S1" +&+ "S2" ;; 

    iSir "S4" ::= "S1" incepand 2 lungime 3 ;;

    iSir "S5" ::= lungimesir "S4" ;;
    
    iList "L" ::= (vectornat [ (numar 1); (numar 2); (numar 3) ]) ;;
    
    (testeaza ( "sum" )
    cazurile ( vectornat [ (numar 1); (numar 2); (numar 3) ] )
    optiunile (  ["sum" :n= 1; "sum" :n= 2; "sum" :n= 3] )
    ) ;; 
    
    iList "L1" ::= lungimelist "L" ;;
    iList "L2" ::= invers "L" ;;
    iList "L3" ::= h( "L" );;
    iList "L4" ::= Primele 2 elemente "L" ;;
    iList "L5" ::= "L3" |+| "L4" ;;

    iNat "i" ::= 1 ;;
    sari_peste "i" :n= 0 incepe
    ("i" ==n 0 atunci "i" :n= 2 altfel "i" :n= 3)
    .

Compute (eval_r example env 100) "L".
Compute (eval_r example env 100) "L1".
Compute (eval_r example env 100) "L2".
Compute (eval_r example env 100) "L3".
Compute (eval_r example env 100) "L4".
Compute (eval_r example env 100) "L5".


Compute (eval_r example env 100) "sum".

Compute (eval_r example env 100) "i".

Compute (eval_r example env 100) "S1".
Compute (eval_r example env 100) "S2".
Compute (eval_r example env 100) "S3".
Compute (eval_r example env 100) "S4".
Compute (eval_r example env 100) "S5".










