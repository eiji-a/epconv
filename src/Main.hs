
module Main where

import Control.Monad
import Data.Char
import Data.Word
import Debug.Trace

type Fingerprint = (String, Bool, [Word8])

main :: IO ()
main = do
  fps <- readFingerprint
  let ms = matchFingerprints fps
  forM_ (ms) $ \i -> do
    putStrLn $ show i

readFingerprint :: IO [Fingerprint]
readFingerprint = do
  c <- getContents
  fps <- forM (lines c) $ \i -> do
    return $ readOneFP i
  return fps

readOneFP :: String -> Fingerprint
readOneFP [] = ("0", False, [])
readOneFP xs = (x, y', z')
  where
    (x:y:z:_) = parseLine xs
    y' = y /= []
    z' = hex2word8 z

parseLine :: String -> [String]
parseLine [] = []
parseLine xs = f:parseLine s
  where
    (f, s) = split (\x -> x == '|') xs

split :: (a -> Bool) -> [a] -> ([a], [a])
split _ [] = ([], [])
split f (x:xs)
  |f x = ([], xs)
  |otherwise = (x:ys, zs)
  where
    (ys, zs) = split f xs

hex2word8 :: String -> [Word8]
hex2word8 [] = []
hex2word8 (x:[]) = []
hex2word8 xs = w:hex2word8 ys
  where fs = take 2 xs
        ys = drop 2 xs
        w = fromIntegral (digitToInt (fs!!0) * 16 + digitToInt (fs!!1)) :: Word8

matchFingerprints :: [Fingerprint] -> [(String, String)]
matchFingerprints xs = compareFingerprints uxs cxs
  where
    uxs = filter (\(_,c,_) -> c == False) xs -- unchecked items
    cxs = filter (\(_,c,_) -> c == True ) xs -- already checked items

compareFingerprints :: [Fingerprint] -> [Fingerprint] -> [(String, String)]
compareFingerprints [] _ = []
compareFingerprints (x:xs) ys = (id, res):(compareFingerprints xs ys)
  where
    (id, _, _) = x
    res = trace (show $ length xs) (roundRobin 8 100 x (xs ++ ys))

-- roundRobin
--   t: threshold of color difference
--   s: percentage of under threshold pixels
roundRobin :: Word8 -> Double -> Fingerprint  -> [Fingerprint] -> String
roundRobin _ _ _ [] = ""
roundRobin t s x (y:ys) = isSame t s x y ++ roundRobin t s x ys

isSame :: Word8 -> Double -> Fingerprint -> Fingerprint -> String
isSame t s (ix, _, fx) (iy, _, fy) = if length over > limit then [] else iy ++ ","
  where
    xy = zip fx fy
    limit = ceiling (fromIntegral (length xy) * (100 - s) / 100.0)
    over = take (limit + 1) $ filter differ xy
    differ :: (Word8, Word8) -> Bool
    differ (a, b) = (if a > b then a - b else b - a) > t
    

putFingerprint :: Fingerprint -> IO ()
putFingerprint (x, y, z) = do
  putStr $ show x
  putStr ","
  putStrLn $ show y
