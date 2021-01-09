{-# OPTIONS --safe #-}

open import Surface.WellScoped

module Surface.WellScoped.Actions (α : VarAction) where

open import Data.Nat using (zero; suc; _+_)
open import Data.Vec

open VarAction α public

var-action-record : VarAction
var-action-record = α

ActionOn : (ℕ → Set) → Set
ActionOn Ty = ∀ {ℓ ℓ'} → (Fin ℓ → Target ℓ') → Ty ℓ → Ty ℓ'

act-ρ : ActionOn Refinement
act-τ : ActionOn SType
act-ε : ActionOn STerm
act-cons : ActionOn (ADTCons nₐ)
act-branches : ActionOn (CaseBranches nₐ)

act-ρ f (ε₁ ≈ ε₂) = act-ε f ε₁ ≈ act-ε f ε₂
act-ρ f (ρ₁ ∧ ρ₂) = act-ρ f ρ₁ ∧ act-ρ f ρ₂

act-τ f ⟨ b ∣ ρ ⟩ = ⟨ b ∣ act-ρ (ext f) ρ ⟩
act-τ f (τ₁ ⇒ τ₂) = act-τ f τ₁ ⇒ act-τ (ext f) τ₂
act-τ f (⊍ cons)  = ⊍ (act-cons f cons)

act-cons _ [] = []
act-cons f (τ ∷ τs) = act-τ f τ ∷ act-cons f τs

act-branches _ [] = []
act-branches f (MkCaseBranch body ∷ bs) = MkCaseBranch (act-ε (ext f) body) ∷ act-branches f bs

act-ε f SUnit = SUnit
act-ε f (SVar idx) = var-action f idx
act-ε f (SLam τ ε) = SLam (act-τ f τ) (act-ε (ext f) ε)
act-ε f (SApp ε₁ ε₂) = SApp (act-ε f ε₁) (act-ε f ε₂)
act-ε f (SCase scrut branches) = SCase (act-ε f scrut) (act-branches f branches)
act-ε f (SCon idx body adt-cons) = SCon idx (act-ε f body) (act-cons f adt-cons)


ext-k : ∀ k
      → (Fin ℓ → Target ℓ')
      → (Fin (k + ℓ) → Target (k + ℓ'))
ext-k zero ρ = ρ
ext-k (suc k) ρ = ext (ext-k k ρ)
