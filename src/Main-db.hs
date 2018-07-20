module Main (
  main
) where

import qualified Data.KdTree.Static as KT
import System.Environment

type Point = (Double, Double, Double)
type Image = (Int, Point, String)

main :: IO ()
main = do
  as <- getArgs
  (fs, imap) <- readMap
  mapM_ (doubli (read (as !! 0) :: Double) imap) fs
  --mapM_ (doubli 1.0 imap) fs

readMap :: IO ([Image], KT.KdTree Double Image)
readMap = do
  is <- getContents
  let
    ims = map (\x -> read x :: Image) $ lines is
    imap = KT.buildWithDist imageToPoints squareDistance ims
  return (ims, imap)

squareDistance :: Image -> Image -> Double
squareDistance (_, (x1, y1, z1), _) (_, (x2, y2, z2), _) =
  (x1 - x2) ** 2.0 + (y1 - y2) ** 2.0 + (z1 - z2) ** 2.0

imageToPoints :: Image -> [Double]
imageToPoints (_, (x, y, z), _) = [x, y, z]

doubli :: Double -> KT.KdTree Double Image -> Image -> IO ()
doubli r imap im = do
  let
    is = KT.inRadius imap r im
  if length is > 1
    then putStrLn $ show is
    else return ()
