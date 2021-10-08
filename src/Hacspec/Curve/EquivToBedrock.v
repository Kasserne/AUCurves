Require Import Theory.WordByWordMontgomery.MontgomeryCurveSpecs.
Require Import Crypto.Curves.Weierstrass.Projective.
Require Import Bedrock.Field.bls12prime.
Require Import Coq.ZArith.ZArith.
Require Import bedrock2.Semantics.
Require Import Crypto.Bedrock.Field.Common.Types.
Require Import Crypto.Arithmetic.WordByWordMontgomery.
Require Import MontgomeryRingTheory.
Require Import Crypto.Arithmetic.UniformWeight.
Require Import Crypto.Util.Decidable Crypto.Algebra.Field.
Require Import Theory.Fields.FieldsUtil.
Require Import Hacspec.Curve.blsprime.
From Coqprime Require Import GZnZ.
Require Import Hacspec.Curve.Bls.
Require Import Hacspec.Curve.BlsProof.
Require Import Field.
Require Import Crypto.Util.ZUtil.Tactics.PullPush.Modulo.
Require Import Theory.WordByWordMontgomery.CurveSpecsEquivalence.

Local Open Scope Z_scope.

(*Parameters to be changed: specify prime and import reification from cache.*)
Require Import Bedrock.Examples.felem_copy_64.
Local Definition felem_suffix := felem_copy_64.aff.
Local Notation m := bls12prime.m.

(*Initializing parameters; do not touch*)
Local Notation bw := width.
Local Notation m' := (@WordByWordMontgomery.m' m bw).
Notation n := (WordByWordMontgomery.n m (@width semantics)).
Local Notation eval := (@WordByWordMontgomery.WordByWordMontgomery.eval bw n).
Local Notation valid := (@WordByWordMontgomery.valid bw n m).
Local Notation from_mont := (@WordByWordMontgomery.from_montgomerymod bw n m m').
Local Notation thisword := (@word semantics).
Local Definition valid_words w := valid (List.map (@Interface.word.unsigned width thisword) w).
Local Definition map_words := List.map (@Interface.word.unsigned width thisword).
Local Notation r := (WordByWordMontgomery.r bw).
Local Notation r' := (WordByWordMontgomery.r' m bw).

(*Lemmas of correctness of parameters to be used for montgomery arithmetic.*)
Lemma r'_correct : (2 ^ bw * r') mod m = 1.
Proof. auto with zarith. Qed.

Lemma m'_correct : (m * m') mod 2 ^ bw = -1 mod 2 ^ bw.
Proof. auto with zarith. Qed.

Lemma bw_big : 0 < bw.
Proof. cbv; auto. Qed.

Lemma m_big : 1 < m.
Proof. cbv; auto. Qed.

Lemma n_nz : n <> 0%nat.
Proof. cbv; discriminate. Qed.

Lemma m_small : m < (2 ^ bw) ^ Z.of_nat n.
Proof. cbv; auto. Qed.

Lemma m_big' : 1 < m.
Proof. cbv; auto. Qed.

Lemma n_small : Z.of_nat n < 2 ^ bw.
Proof. cbv. auto. Qed.

Section G1Equiv.
    
    Local Notation a := (0 mod m).
    Local Notation b := (4 mod m).

    Local Notation three_b := (3 * b mod m).
    Local Notation uw := (uweight bw).
    Notation three_b_list := (MontgomeryCurveSpecs.three_b_list bw n three_b).

    Lemma a_small : a = a mod m.
    Proof. auto. Qed.

    Lemma b_small : b = b mod m.
    Proof. auto. Qed.

    Lemma three_b_small : three_b = three_b mod m.
    Proof. auto. Qed.

    (** G1 Equivalence section **)

    Local Notation BLS12_add_Gallina_spec :=
        (BLS12_add_Gallina_spec m bw n m' a three_b).

    Local Infix "*'" := (my_mul m) (at level 40).
    Local Infix "+'" := (my_add m) (at level 50).
    Local Infix "-'" := (my_sub m) (at level 50).

    Local Infix "*m" := (mul m) (at level 40).
    Local Infix "+m" := (add m) (at level 50).
    Local Infix "-m" := (sub m) (at level 50).

    Local Notation fp_a := (mkznz m a a_small).
    Local Notation fp_b := (mkznz m b b_small).
    Local Notation fc_field := (ZpZfc m blsprime).

    Lemma three_small : 3 < m.
    Proof. reflexivity. Qed.

    Local Notation char_ge_3 := (Char_geq_p m (N.succ_pos N.two) three_small).

    Local Notation fp_dec := (fp_dec m).

    Local Notation fp_3_b := (mkznz m three_b three_b_small).

    Lemma three_b_correct : three_b = b + b + b.
    Proof. auto. Qed.

    Lemma fp_3_b_correct : fp_3_b = fp_b +m fp_b +m fp_b. 
    Proof. apply zirr; reflexivity. Qed.

    Lemma discriminant_nonzero: id(((mkznz m _ (modz m 4)) *m fp_a *m fp_a *m fp_a +m (mkznz m _ (modz m 27)) *m fp_b *m fp_b) <> (zero m)).
    Proof. unfold zero, add. cbn. congruence. Qed.

    Lemma twenty1_small : 21 < m.
    Proof. reflexivity. Qed.

    Local Notation char_ge_21 := (Char_geq_p m 21%positive twenty1_small).

    (* Notation for fiat-crypto specifications/lemmas *)
    Local Notation fc_proj_point := (@Projective.point (znz m) (@eq (znz m)) (zero m) (add m) (mul m) fp_a fp_b).
    Local Notation fc_proj_add := (@Projective.add (znz m) (@eq (znz m)) (zero m) (one m) (opp m) (add m) (sub m) (mul m) (inv m) (div m) fp_a fp_b fc_field char_ge_3 fp_dec fp_3_b fp_3_b_correct discriminant_nonzero char_ge_21).
    Local Notation fc_proj_eq := (@Projective.eq (znz m) (@eq (znz m)) (zero m) (add m) (mul m) fp_a fp_b fp_dec).

    Local Notation to_affine := (@Projective.to_affine (znz m) (@eq (znz m)) (zero m) (one m) (opp m) (add m) (sub m) (mul m) (inv m) (div m) fp_a fp_b fc_field fp_dec).
    Local Notation to_affine_add := (@Projective.to_affine_add (znz m) (@eq (znz m)) (zero m) (one m) (opp m) (add m) (sub m) (mul m) (inv m) (div m) fp_a fp_b fc_field char_ge_3 fp_dec fp_3_b fp_3_b_correct discriminant_nonzero char_ge_21).
    Local Notation not_exceptional := (@Projective.not_exceptional (znz m) (@eq (znz m)) (zero m) (one m) (opp m) (add m) (sub m) (mul m) (inv m) (div m) fp_a fp_b fc_field char_ge_3 fp_dec).

    Local Infix "?=?" := g1_eq (at level 70).
    Local Notation of_affine := (@Projective.of_affine (znz m) (@eq (znz m)) (zero m) (one m) (opp m) (add m) (sub m) (mul m) (inv m) (div m) fp_a fp_b fc_field fp_dec ).
    Local Notation fc_eq_iff_Weq := (@Projective.eq_iff_Weq (znz m) (@eq (znz m)) (zero m) (one m) (opp m) (add m) (sub m) (mul m) (inv m) (div m) fp_a fp_b fc_field fp_dec).

    Local Notation fc_aff_point := (@WeierstrassCurve.W.point (znz m) (@eq (znz m)) (add m) (mul m) fp_a fp_b).
    Local Notation fc_aff_eq := (@WeierstrassCurve.W.eq (znz m) (@eq (znz m)) (add m) (mul m) fp_a fp_b).
    Local Notation fc_aff_add := (@WeierstrassCurve.W.add (znz m) (@eq (znz m)) (zero m) (one m) (opp m) (add m) (sub m) (mul m) (inv m) (div m) fc_field fp_dec char_ge_3 fp_a fp_b).

    Local Notation to_fc_point_from_mont := (to_fc_point_from_mont m bw n m' a b three_b a_small b_small three_b_small three_b_correct).

    Definition BLS_gallina_fiat_crypto_equiv' := (gallina_fiat_crypto_equiv' m bw n m' a b three_b a_small b_small three_b_small three_b_correct bw_big n_nz m_small m_big twenty1_small blsprime discriminant_nonzero).
    Local Notation gallina_spec_from_fc_point := (gallina_spec_from_fc_point m bw n m' a b three_b a_small b_small).

    Definition BLS_gallina_fiat_crypto_equiv'' := 
        (gallina_fiat_crypto_equiv'' m bw n r' m' a b three_b a_small b_small three_b_small three_b_correct r'_correct m'_correct bw_big n_nz m_small m_big twenty1_small blsprime discriminant_nonzero).

    Definition to_hacspec_point (X1 Y1 Z1 : list Z) on_curve : g1 := g1_from_fc (to_affine (to_fc_point_from_mont X1 Y1 Z1 on_curve)).

    Add Field hs_fp_field: fp_field_theory.

    Lemma preserves_on_curve : forall p, g1_on_curve (g1_from_fc p).
    Proof. intros [[[] | []]]; cbn; auto.  rewrite y. field.
    Qed.

    Lemma g1_fc_eq: forall x y :fc_aff_point, g1_from_fc x ?=? g1_from_fc y <-> fc_aff_eq x y.
    Proof.
        intros [[[] | []]] [[[] | []]]; unfold "?=?", fc_aff_eq; cbn; easy.
    Qed.

    Lemma same_field_opp : forall x, Lib.nat_mod_neg x = opp m x.
    Proof. intros. reflexivity. Qed.

    Lemma dec_same: forall X x y (a b: X), (if (g1_dec x y) then a else b) = if (fp_dec x y) then a else b. 
    Proof. intros. destruct (g1_dec x y); destruct (fp_dec x y); try reflexivity; try contradiction.
    Qed. 

    Lemma same_fc_add: forall x y, fc_aff_eq (g1_fc_add x y) (fc_aff_add x y).
    Proof. intros [[[] | []]] [[[] | []]]; unfold g1_fc_add; unfold fc_aff_add; unfold fc_aff_eq; cbn; auto.
    unfold dec. do 2 rewrite dec_same. rewrite same_field_opp. destruct (fp_dec f f1); destruct (fp_dec f2 (opp m f0));
        try trivial; split; reflexivity.
    Qed.

    Lemma fc_aff_eq_refl: forall x, fc_aff_eq x x.
    Proof. intros [[[]| []]]; cbn; auto.
    Qed.

    Lemma fc_aff_eq_symm: forall x y, fc_aff_eq x y -> fc_aff_eq y x.
    Proof. intros [[[] | []]] [[[] | []]]; unfold fc_aff_eq; cbn; intros []; auto.
    Qed.

    Lemma fc_aff_eq_trans: forall x y z, fc_aff_eq x y -> fc_aff_eq y z -> fc_aff_eq x z.
    Proof.  intros [[[] | []]] [[[] | []]] [[[] | []]]; unfold fc_aff_eq; cbn; intros [] []; subst; auto.
    Qed. 

    Add Relation fc_aff_point fc_aff_eq
        reflexivity proved by fc_aff_eq_refl
        symmetry proved by fc_aff_eq_symm
        transitivity proved by fc_aff_eq_trans
        as fc_aff_rel.

    Lemma fc_aff_eq_sig: forall x y, proj1_sig x = proj1_sig y -> fc_aff_eq x y.
    Proof. intros [[[] | []]] [[[] | []]]; cbn; intros H; inversion H; auto.
    Qed.

    Lemma fc_aff_add_compat: forall x y, fc_aff_eq (fc_aff_add x y) (fc_aff_add (g1_to_fc (g1_from_fc x) (preserves_on_curve _)) (g1_to_fc (g1_from_fc y) (preserves_on_curve _))).
    Proof. intros [[[] | []]] [[[] | []]]; apply fc_aff_eq_sig; cbn; reflexivity.
    Qed.

    (* Gallina to hacspec equivalence *)
    Lemma gallina_hacspec_equiv : forall X1 Y1 Z1 X2 Y2 Z2 outx outy outz on_curve1 on_curve2 on_curve_out (except: not_exceptional (to_fc_point_from_mont _ _ _ on_curve1) (to_fc_point_from_mont _ _ _ on_curve2)), 
        (BLS12_add_Gallina_spec X1 Y1 Z1 X2 Y2 Z2 outx outy outz ->
        (to_hacspec_point outx outy outz on_curve_out ?=? g1add (to_hacspec_point X1 Y1 Z1 on_curve1) (to_hacspec_point X2 Y2 Z2 on_curve2))).
    Proof. intros. apply (BLS_gallina_fiat_crypto_equiv' _ _ _ _ _ _ _ _ _ on_curve1 on_curve2 on_curve_out except) in H.
        unfold to_hacspec_point. rewrite (g1_addition_equal _ _ (preserves_on_curve (to_affine (to_fc_point_from_mont X1 Y1 Z1 on_curve1))) (preserves_on_curve (to_affine (to_fc_point_from_mont X2 Y2 Z2 on_curve2)))).
        apply g1_fc_eq. rewrite same_fc_add. rewrite <- fc_aff_add_compat. rewrite <- (to_affine_add _ _ except). 
        apply fc_eq_iff_Weq. apply H.
    Qed.

    (* Hacspec to gallina equivalence *)
    Lemma gallina_hacspec_equiv' : forall p1 p2 pout (except : not_exceptional p1 p2), 
        g1_from_fc (to_affine pout) ?=? g1add (g1_from_fc (to_affine p1)) (g1_from_fc (to_affine p2)) ->
        exists pout', fc_proj_eq pout pout' /\ gallina_spec_from_fc_point p1 p2 pout'.
    Proof.
        intros. assert (fc_proj_eq pout (fc_proj_add p1 p2 except)).
        { apply fc_eq_iff_Weq. rewrite (to_affine_add). apply g1_fc_eq. rewrite H. 
        rewrite (g1_addition_equal _ _ (preserves_on_curve _) (preserves_on_curve _)). apply g1_fc_eq. rewrite same_fc_add. rewrite <- fc_aff_add_compat. reflexivity. }
        apply (BLS_gallina_fiat_crypto_equiv'' _ _ _ except) in H0. apply H0. 
    Qed.

End G1Equiv.

Section G2Equiv.
    (** G2 Equivalence section **)
    Require Import Crypto.Arithmetic.Partition.
    Require Import Theory.Fields.QuadraticFieldExtensions.
    Require Import Crypto.Algebra.Hierarchy.
    Local Open Scope Z_scope.

    (* Some notation and definitions*)
    Local Notation ar := (0 mod m).
    Local Notation ai := (0 mod m).
    Local Notation br := (4 mod m).
    Local Notation bi := (4 mod m).

    (*Initializing parameters; do not touch*)
    Local Notation three_br := (3 * br mod m).
    Local Notation three_bi := (3 * bi mod m).
    Local Notation uw := (uweight 64).
    Definition three_br_list := (Partition.partition uw 6 (three_br)).
    Definition three_bi_list := (Partition.partition uw 6 three_bi).

    Lemma ar_small : ar = ar mod m.
    Proof. auto. Qed.

    Lemma ai_small : ai = ai mod m.
    Proof. auto. Qed.

    Lemma br_small : br = br mod m.
    Proof. auto. Qed.

    Lemma bi_small : bi = bi mod m.
    Proof. auto. Qed.

    Lemma three_br_small : three_br = three_br mod m.
    Proof. auto. Qed.

    Lemma three_bi_small : three_bi = three_bi mod m.
    Proof. auto. Qed.

    Lemma three_br_correct : three_br = br + br + br.
    Proof. auto. Qed.

    Lemma three_bi_correct : three_bi = bi + bi + bi.
    Proof. auto. Qed.

    Local Notation BLS12_G2_add_Gallina_spec :=
        (@BLS12_G2_add_Gallina_spec m bw n m' 0 0 three_br three_bi).

    Local Infix "*p2'" := (my_mulFp2 m) (at level 40).
    Local Infix "+p2'" := (my_addFp2 m) (at level 50).
    Local Infix "-p2'" := (my_subFp2 m) (at level 50).

    Local Infix "*m2" := (mulp2 m) (at level 40).
    Local Infix "+m2" := (addp2 m) (at level 50).
    Local Infix "-m2" := (subp2 m) (at level 50).

    Local Notation Fp2 := (znz m * znz m)%type.
    Local Notation fp2_a := (mkznz m ar ar_small, mkznz m ai ai_small).
    Local Notation fp2_b := (mkznz m br br_small, mkznz m bi bi_small).
    Local Notation fp2_3_b := (mkznz m three_br three_br_small, mkznz m three_bi three_bi_small).

    Lemma m_odd: 2 < m.
    Proof. reflexivity. Qed.

    Lemma m_mod3: m mod 4 =? 3 = true.
    Proof. reflexivity. Qed.

    Lemma m_mod: m mod 4 = 3.
    Proof. auto. Qed.

    Local Notation FFp2 := ((@FFp2 m) blsprime m_odd m_mod3).

    Local Notation fp2_fc_field := (Fp2fc m blsprime m_odd m_mod3).
    Local Notation fp2_char_ge_3 := (Char_Fp2_geq_p m blsprime 3 three_small).
    Local Notation fp2_char_ge_21 := (Char_Fp2_geq_p m blsprime 21 twenty1_small).

    Local Notation fc_fp2_dec := (fc_fp2_dec m).

    Lemma mul_zero_r: forall x, mul m x (zero m) = zero m.
    Proof. intros []. unfold mul. cbn. rewrite Z.mul_0_r. reflexivity. 
    Qed.

    Lemma fp2_discriminant_nonzero: id(((mkznz m _ (modz m 4), zero m) *m2 fp2_a *m2 fp2_a *m2 fp2_a +m2 (mkznz m _ (modz m 27), zero m) *m2 fp2_b *m2 fp2_b) <> (zerop2 m)).
    Proof.  unfold id, zerop2, addp2, mulp2, fst, snd.  
        intros c. apply pair_equal_spec in c. destruct c.  repeat rewrite mul_zero_r in H0. discriminate H0.
    Qed.

    Local Notation fp2_3_b_correct := (fp2_3_b_correct m br bi three_br three_bi br_small bi_small three_br_small three_bi_small three_br_correct three_bi_correct).

    Local Notation fc_proj_p2_point := (@Projective.point Fp2 eq (zerop2 m) (addp2 m) (mulp2 m) fp2_a fp2_b).
    Local Notation fc_proj_p2_add :=  (@Projective.add Fp2 eq (zerop2 m) (onep2 m) (oppp2 m) (addp2 m) (subp2 m) (mulp2 m) (invp2 m) (divp2 m) fp2_a fp2_b fp2_fc_field fp2_char_ge_3 fc_fp2_dec fp2_3_b fp2_3_b_correct fp2_discriminant_nonzero fp2_char_ge_21).
    Local Notation fc_proj_p2_eq := (@Projective.eq Fp2 eq (zerop2 m) (addp2 m) (mulp2 m) fp2_a fp2_b fc_fp2_dec).

    Definition BLS_gallina_fiat_crypto_p2_equiv' :=  (gallina_fiat_crypto_p2_equiv' m bw n m' ar ai br bi three_br three_bi ar_small ai_small br_small bi_small three_br_small three_br_small three_br_correct three_bi_correct
        bw_big n_nz m_small m_big m_mod blsprime m_odd twenty1_small fp2_discriminant_nonzero).
  
    Definition BLS_gallina_fiat_crypto_p2_equiv'' := (gallina_fiat_crypto_p2_equiv'' m bw n r' m' ar ai br bi three_br three_bi ar_small ai_small br_small bi_small three_br_small three_br_small three_br_correct three_bi_correct
        r'_correct m'_correct bw_big n_nz m_small m_big m_mod blsprime m_odd twenty1_small fp2_discriminant_nonzero).

    (* TODO: Add proof of equivalence between G2 hacspec and gallina *)

End G2Equiv.