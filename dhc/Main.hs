-- Takes Haskell source given on standard input and compiles it to
-- WebAssembly which is dumped to standard output.

import qualified Data.ByteString as B
import Asm
import CWA

main :: IO ()
main = do
  s <- getContents
  case hsToWasm cwaBoost s of
    Left err -> error err
    Right bin -> B.putStr $ B.pack $ fromIntegral <$> bin
