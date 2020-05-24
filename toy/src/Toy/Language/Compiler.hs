{-# LANGUAGE RecordWildCards, QuasiQuotes, LambdaCase #-}

module Toy.Language.Compiler where

import Data.List
import Data.Maybe
import Data.String.Interpolate

import Toy.Language.Syntax.Decls
import Toy.Language.Syntax.Types

compileFunSig :: FunSig -> String
compileFunSig FunSig { .. } = [i|#{funName} : #{compileTy funTy}|]

compileTy :: Ty -> String
compileTy (TyBase RefinedBaseTy { .. })
  | baseTyRefinement == trueRefinement = compileBaseTy baseType
  | otherwise = [i|(v : #{compileBaseTy baseType} ** #{compileRefinement baseTyRefinement})|]
compileTy (TyArrow ArrowTy { .. })
  | isBaseTy domTy || isJust piVarName = [i|#{lhs} -> #{compileTy codTy}|]
  | otherwise = [i|(#{lhs}) -> #{compileTy codTy}|]
  where
    lhs | Just name <- piVarName = [i|(#{getName name} : #{compileTy domTy})|]
        | otherwise = compileTy domTy

compileRefinement :: Refinement -> String
compileRefinement refinement =
  case conjuncts refinement of
       [] -> "()"
       [conj] -> compileAR conj
       conjs -> "(" <> intercalate ", " (compileAR <$> conjs) <> ")"

compileAR :: AtomicRefinement -> String
compileAR (AR op arg) = [i|v #{opStr} #{argStr} = True|]
  where
    opStr = case op of
                 ROpLt -> "<"
                 ROpLeq -> "<="
                 ROpEq -> "=="
                 ROpNEq -> "/="
                 ROpGt -> ">"
                 ROpGeq -> ">="
    argStr = case arg of
                  RArgInt n -> show n
                  RArgVar var -> getName var
                  RArgVarLen var -> "intLength " <> getName var

compileBaseTy :: BaseTy -> String
compileBaseTy TBool = "Bool"
compileBaseTy TInt = "Int"
compileBaseTy TIntList = "List Int"

compileFunDef :: FunDef -> String
compileFunDef FunDef { .. } = [i|#{funName} #{unwords funArgsNames} = #{compileTerm funBody}|]
  where
    funArgsNames = getName <$> funArgs

compileTerm :: Term -> String
compileTerm (TName _ var) = getName var
compileTerm (TInteger _ n) = show n
compileTerm (TBinOp _ t1 op t2) = [i|#{compileTerm t1} #{compileOp op} #{compileTerm t2}|]

compileOp :: BinOp -> String
compileOp = \case BinOpPlus -> "+"
                  BinOpMinus -> "-"
                  BinOpGt -> ">"
                  BinOpLt -> "<"
