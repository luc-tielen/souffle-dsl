
{-# OPTIONS_GHC -optc-std=c++17 -D__EMBEDDED_SOUFFLE__ #-}
{-# LANGUAGE TypeApplications, TemplateHaskell #-}
module Test.Language.Souffle.DSL.FixturesCompiled () where

-- NOTE: this module can't be grouped together with "Fixtures"
-- due to TemplateHaskell staging restriction.

import Test.Language.Souffle.DSL.Fixtures
import Language.Souffle.DSL

$(embedProgram CompiledProgram $ do
  Predicate edge <- predicateFor @Edge
  Predicate reachable <- predicateFor @Reachable
  a <- var "a"
  b <- var "b"
  c <- var "c"
  reachable(a, b) |- edge(a, b)
  reachable(a, b) |- do
    edge(a, c)
    reachable(c, b)
 )
