{-# LANGUAGE UndecidableInstances #-} -- for natural subtraction

module Symparsec.Parser.Skip ( Skip, Skip' ) where

import Symparsec.Parser.Common
import GHC.TypeLits ( Natural, type (-) )
import TypeLevelShow.Natural ( ShowNatDec )

-- | Skip forward @n@ characters. Fails if fewer than @n@ characters are
--   available.
type Skip :: Natural -> Parser Natural ()
type family Skip n where
    Skip 0 = 'Parser
        (FailChSym "Skip" (ErrParserLimitation "can't drop 0")) SkipEndSym 0
    Skip n = Skip' n

-- | Unsafe 'Skip' which doesn't check for @n=0@. May get stuck.
type Skip' :: Natural -> Parser Natural ()
type Skip' n = 'Parser SkipChSym SkipEndSym n

type SkipCh :: PParserCh Natural ()
type family SkipCh ch n where
    SkipCh _ 1 = Done '()
    SkipCh _ n = Cont (n-1)

type SkipEnd :: PParserEnd Natural ()
type family SkipEnd n where
    SkipEnd 0 = Right '()
    SkipEnd n = Left (EBase "Skip"
        (      Text "tried to drop "
          :<>: Text (ShowNatDec n) :<>: Text " chars from empty symbol"))

type SkipChSym :: ParserChSym Natural ()
data SkipChSym f
type instance App SkipChSym f = SkipChSym1 f

type SkipChSym1 :: Char -> Natural ~> PResult Natural ()
data SkipChSym1 ch n
type instance App (SkipChSym1 ch) n = SkipCh ch n

type SkipEndSym :: ParserEndSym Natural ()
data SkipEndSym n
type instance App SkipEndSym n = SkipEnd n
