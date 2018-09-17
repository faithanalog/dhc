-- DHC Boost that provides 2 functions:
--
--   putStr :: String -> IO ()
--   putInt :: Int -> IO ()
--
-- and expects the host to provide 2 syscalls:
--
--  system.putStr (pointer : I32, length : I32) -> ()
--  system.putInt (n : I64) -> ()
--
-- The JavaScript edition expects a variant of system.putInt:
--
--  system.putInt (lo : I32, hi : I32) -> ()
module CWA (cwaBoost) where

import Ast
import Boost
import WasmOp

sp :: Int
sp = 0

cwaBoost :: Boost
cwaBoost =
  Boost
    [(("cwa", "log_write"), ([I32, I32, I32], []))]
    []
    [("putStr", (TC "String" :-> io (TC "()"), putStrAsm))]
    []
  where
    io = TApp (TC "IO")

-- The JavaScript edition of the host splits an int64 into low and high 32-bit
-- words, since current JavaScript engines lack support for 64-bit integers.

putStrAsm :: [QuasiWasm]
putStrAsm =
  [ Custom $ ReduceArgs 1
  , I32_const 6
  , Get_global sp  -- system.putStr ([[sp + 4] + 4] [[sp + 4] + 8]) [[sp + 4] + 12]
  , I32_load 2 4
  , I32_load 2 4
  , Get_global sp
  , I32_load 2 4
  , I32_load 2 8
  , I32_add
  , Get_global sp
  , I32_load 2 4
  , I32_load 2 12
  , Custom $ CallSym "cwa.log_write"
  , Get_global sp  -- sp = sp + 12
  , I32_const 12
  , I32_add
  , Set_global sp
  , Custom $ CallSym "#nil42"
  , End
  ]
