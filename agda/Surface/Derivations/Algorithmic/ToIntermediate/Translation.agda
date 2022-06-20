module Surface.Derivations.Algorithmic.ToIntermediate.Translation where

open import Data.Fin using (suc; zero)
open import Relation.Binary.PropositionalEquality using (_≡_; refl)

open import Surface.Syntax as S
import Surface.Syntax.Membership as S
import Surface.Syntax.Substitution as S
open import Surface.Derivations.Algorithmic as S
open import Surface.Derivations.Algorithmic.Theorems.Agreement

open import Intermediate.Syntax as I
open import Intermediate.Syntax.Short
open import Intermediate.Syntax.Renaming as IR
import Intermediate.Syntax.Membership as I
import Intermediate.Derivations.Algorithmic as I

open import Surface.Derivations.Algorithmic.ToIntermediate.Translation.Aliases
open import Surface.Derivations.Algorithmic.ToIntermediate.Translation.Subst
open import Surface.Derivations.Algorithmic.ToIntermediate.Translation.Typed

μ-∈ : (Γok : Γˢ ok[ θˢ , E ])
    → (τδ : Γˢ ⊢[ θˢ , E ] τˢ)
    → (τˢ S.∈ Γˢ at ι)
    → (μ-τ τδ I.∈ μ-Γ Γok at ι)
μ-∈ (TCTX-Bind _ τδ') τδ (S.∈-zero refl) = I.∈-zero {! !}
μ-∈ (TCTX-Bind Γok _) τδ' (S.∈-suc refl ∈)
  = let τδ = τ∈Γ-⇒-Γ⊢τ Γok ∈
     in I.∈-suc {! !} (μ-∈ Γok τδ ∈)

mutual
  μ-ε-δ : {τˢ : SType ℓ}
        → (εδ : Γˢ ⊢[ θˢ , E of κ ] εˢ ⦂ τˢ)
        → [ θⁱ ] μ-Γ (Γ⊢ε⦂τ-⇒-Γok εδ) ⊢ μ-ε εδ ⦂ μ-τ (Γ⊢ε⦂τ-⇒-Γ⊢τ εδ)
  μ-ε-δ (T-Unit Γok) = T-Unit (μ-Γ-δ Γok)
  μ-ε-δ (T-Var Γok ∈) = T-Var (μ-Γ-δ Γok) (μ-∈ Γok (τ∈Γ-⇒-Γ⊢τ Γok ∈) ∈)
  μ-ε-δ (T-Abs τ₁⇒τ₂δ@(TWF-Arr τ₁δ τ₂δ) εδ)
    = let εδⁱ = μ-ε-δ εδ
          εδⁱ = subst-Γ⊢ε⦂[τ] _ τ₂δ εδⁱ
          εδⁱ = subst-[Γ]⊢ε⦂τ _ _   εδⁱ
       in T-Abs (μ-τ-δ τ₁⇒τ₂δ) εδⁱ
  μ-ε-δ (T-App ε₁δ ε₂δ refl resτδ)
    with τ₁⇒τ₂δ@(TWF-Arr τ₁δ τ₂δ) ← Γ⊢ε⦂τ-⇒-Γ⊢τ ε₁δ
    = let ε₁δⁱ = μ-ε-δ ε₁δ
          ε₁δⁱ = subst-Γ⊢ε⦂[τ] (Γ⊢ε⦂τ-⇒-Γ⊢τ ε₁δ) τ₁⇒τ₂δ ε₁δⁱ
          ε₂δⁱ = μ-ε-δ ε₂δ
          ε₂δⁱ = subst-Γ⊢ε⦂[τ] _ τ₁δ ε₂δⁱ
          ε₂δⁱ = subst-[Γ]⊢ε⦂τ _ _   ε₂δⁱ
          resτδⁱ = subst-[Γ]⊢τ _ _ (μ-τ-δ resτδ)
       in T-App ε₁δⁱ ε₂δⁱ {! !} resτδⁱ
  μ-ε-δ (T-Case resδ εδ branches-well-typed) = {! !}
  μ-ε-δ (T-Con ≡-prf εδ adtτ) = {! !}
  μ-ε-δ (T-Sub εδ τ'δ <:δ)
    = let εδⁱ = μ-ε-δ εδ
          <:δⁱ = μ-<:-δ (Γ⊢ε⦂τ-⇒-Γok εδ) (Γ⊢ε⦂τ-⇒-Γ⊢τ εδ) τ'δ <:δ
          τ'δⁱ = subst-[Γ]⊢τ _ _ (μ-τ-δ τ'δ)
       in T-App <:δⁱ εδⁱ {! !} τ'δⁱ

  μ-τ-δ : {τˢ : SType ℓ}
        → (τδ : Γˢ ⊢[ θˢ , E ] τˢ)
        → [ θⁱ ] μ-Γ (Γ⊢τ-⇒-Γok τδ) ⊢ μ-τ τδ
  μ-τ-δ τδ = {! !}

  μ-<:-δ : {τ'ˢ τˢ : SType ℓ}
         → (Γok : Γˢ ok[ θˢ , E ])
         → (τ'δ : Γˢ ⊢[ θˢ , E ] τ'ˢ)
         → (τδ : Γˢ ⊢[ θˢ , E ] τˢ)
         → (<:δ : Γˢ ⊢[ θˢ , E ] τ'ˢ <: τˢ)
         → [ θⁱ ] μ-Γ Γok ⊢ μ-<: <:δ ⦂ μ-τ τ'δ ⇒ IR.weaken-τ (μ-τ τδ)
  μ-<:-δ = {! !}

  μ-Γ-δ : (Γok : Γˢ ok[ θˢ , E ])
        → [ θⁱ ] μ-Γ Γok ok
  μ-Γ-δ TCTX-Empty = TCTX-Empty
  μ-Γ-δ (TCTX-Bind Γok τδ) = TCTX-Bind (μ-Γ-δ Γok) (subst-[Γ]⊢τ _ _ (μ-τ-δ τδ))
