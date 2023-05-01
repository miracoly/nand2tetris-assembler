{-# LANGUAGE OverloadedStrings #-}

module Hack.Assembler.Internal (module Hack.Assembler.Internal) where

import Control.Applicative (ZipList (..), liftA2)
import Data.Maybe (fromMaybe)
import Data.Text as T (Text, elem, filter, head, length, lines, strip, stripSuffix, tail, take, unlines, unpack)
import Data.Text.Read (Reader, decimal)
import Numeric (showBin)
import Prelude as P hiding (dropWhile, elem, length, lines, take, unlines)

-- | Represent CPU Instruction of Hack Computer.
--
-- Read the complete [specification of the Hack instructions](https://www.nand2tetris.org/_files/ugd/44046b_89a8e226476741a3b7c5204575b8a0b2.pdf) for in-depth explanation.
data Instruction
  = -- | A instruction with 15 Bit value.
    A' Int
  | -- | C instruction consisting of 13 Bit command.
    C'
      { -- | 1 Bit value. When 0 computation is done with value of A Register, otherwise with memory value A register points to.
        _a :: Int,
        -- | 6 Bit computation instruction of the ALU
        _comp :: Int,
        -- | 3 Bit value which defines the destination where the result of the ALU computation is written to.
        _dest :: Int,
        -- | 3 Bit value which defines when to jump.
        _jump :: Int
      }
  deriving (Eq)

instance Show Instruction where
  show i = case i of
    A' n -> "A " <> showBin n ""
    C' a c d j -> "C " <> unwords (getZipList $ liftA2 showBin (ZipList [a, c, d, j]) $ ZipList $ repeat "")

type ParseErrorDescription = String

-- | Parse single Instruction and return 'Data.Either.Right' 'Instruction' if instruction could be parsed,
-- otherwise 'Data.Either.Left' 'ParseErrorDescription'.
parseInstruction :: Text -> Either ParseErrorDescription Instruction
parseInstruction instr
  | length instr < 2 = Left $ "Could not parse " <> unpack instr
  | otherwise =
    let h = T.head instr
        address = T.tail instr
     in case h of
          '@' -> parseA address
          _ -> parseC instr

-- | Parse single __A__ Instruction and return 'Data.Either.Right' 'Instruction' if @'address'@ is between 1 and 32767 (15 Bit),
-- otherwise 'Data.Either.Left' 'ParseErrorDescription'.
parseA :: Text -> Either ParseErrorDescription Instruction
parseA address = (decimal :: Reader Int) address >>= toInstr
  where
    toInstr (a, _)
      | a < 1 = Left $ "Address " <> unpack address <> " is less than 1."
      | a > 32767 = Left $ "Address " <> unpack address <> " is bigger than 15 bits."
      | otherwise = Right $ A' a

parseC = undefined

-- | Remove whitespaces, empty lines and comments.
cleanUpCode :: Text -> Text
cleanUpCode =
  fromMaybe ""
    . stripSuffix "\n"
    . unlines
    . P.filter isCode
    . T.lines
    . T.filter (/= ' ')

-- | Return True if Text does NOT contain any white spaces, new lines or comments, otherwise False.
isCode :: Text -> Bool
isCode = and . fmap not . sequenceA [isComment, (== ""), (== "\n"), elem ' ', elem '\n']

-- | Return True if Text is comment, otherwise False.
isComment :: Text -> Bool
isComment = (== "//") . take 2 . strip
