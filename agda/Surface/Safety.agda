{-# OPTIONS --safe #-}

module Surface.Safety where

open import Data.Nat using (zero)

open import Surface.WellScoped
open import Surface.Derivations
open import Surface.Operational

data Canonical : STerm ℓ → SType ℓ → Set where
  C-Unit : Canonical (SUnit {ℓ}) ⟨ BUnit ∣ Τ ⟩
  C-Lam  : (lam-δ : ⊘ ⊢ SLam τ₁ ε ⦂ τ₁ ⇒ τ₂)
         → Canonical (SLam τ ε) (τ₁ ⇒ τ₂)
  C-Con  : ∀ {cons : ADTCons (Mkℕₐ (suc n)) zero}
         → (con-δ : ⊘ ⊢ SCon idx ε cons ⦂ ⊍ cons)
         → (scrut-canonical : Canonical ε τ)
         → Canonical (SCon idx ε cons) (⊍ cons)

canonical : ⊘ ⊢ ε ⦂ τ
          → IsValue ε
          → Canonical ε τ
canonical (T-Var _ _) ()
canonical (T-App _ _) ()
canonical (T-Case _ _ _) ()
canonical (T-Unit Γok) IV-Unit = C-Unit
canonical (T-Abs arrδ εδ) IV-Abs = C-Lam (T-Abs arrδ εδ)
canonical (T-Con εδ adtτ) (IV-ADT is-value) = C-Con (T-Con εδ adtτ) (canonical εδ is-value)
canonical (T-Sub εδ Γ⊢τ' <:) IV-Unit = {! !}
canonical (T-Sub εδ Γ⊢τ' <:) IV-Abs = {! !}
canonical (T-Sub εδ Γ⊢τ' <:) (IV-ADT is-value) = {! !}


data Progress (ε : STerm ℓ) : Set where
  step : (ε↝ε' : ε ↝ ε')
       → Progress ε
  done : (is-value : IsValue ε)
       → Progress ε

progress : ⊘ ⊢ ε ⦂ τ
         → Progress ε
progress (T-Unit Γok) = done IV-Unit
progress (T-Abs arrδ εδ) = done IV-Abs
progress (T-App {ε₂ = ε₂} εδ₁ εδ₂) with progress εδ₁
... | step ε↝ε' = step (E-AppL ε↝ε')
... | done is-value-ε₁ with progress εδ₂
...   | step ε↝ε' = step (E-AppR is-value-ε₁ ε↝ε')
...   | done is-value-ε₂ with canonical εδ₁ is-value-ε₁
...     | C-Lam lam-δ = step (E-AppAbs is-value-ε₂)
progress (T-Case resδ εδ branches) with progress εδ
... | step ε↝ε' = step (E-CaseScrut ε↝ε')
... | done is-value with canonical εδ is-value
...   | C-Con con-δ scrut-canonical with is-value
...     | IV-ADT ε-value = step (E-CaseMatch ε-value)
progress (T-Con εδ adtτ) with progress εδ
... | step ε↝ε' = step (E-ADT ε↝ε')
... | done is-value = done (IV-ADT is-value)
progress (T-Sub εδ τδ τ<:τ') = progress εδ
