{-# OPTIONS --safe #-}

module Core.Syntax.Renaming where

open import Data.Nat using (zero; suc)
open import Data.Fin using (zero; suc)

open import Core.Syntax
open import Core.Syntax.Actions (record { Target = Fin
                                        ; var-action = λ ι → CVar ι
                                        ; ext = λ where _ zero → zero
                                                        ρ (suc n) → suc (ρ n)
                                        }) public

weaken-ε : CExpr ℓ → CExpr (suc ℓ)
weaken-ε = act-ε suc

weaken-cons : ADTCons nₐ ℓ → ADTCons nₐ (suc ℓ)
weaken-cons = act-cons suc

weaken-ε-k : ∀ k → CExpr ℓ → CExpr (k + ℓ)
weaken-ε-k zero ε = ε
weaken-ε-k (suc k) ε = weaken-ε (weaken-ε-k k ε)
