-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Eptank.Object.Image exposing (..)

import Eptank.Enum.ImageStatus
import Eptank.InputObject
import Eptank.Interface
import Eptank.Object
import Eptank.Scalar
import Eptank.ScalarCodecs
import Eptank.Union
import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode as Encode exposing (Value)
import Graphql.Operation exposing (RootMutation, RootQuery, RootSubscription)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode


filename : SelectionSet String Eptank.Object.Image
filename =
    Object.selectionForField "String" "filename" [] Decode.string


filesize : SelectionSet Int Eptank.Object.Image
filesize =
    Object.selectionForField "Int" "filesize" [] Decode.int


id : SelectionSet Int Eptank.Object.Image
id =
    Object.selectionForField "Int" "id" [] Decode.int


liked : SelectionSet Bool Eptank.Object.Image
liked =
    Object.selectionForField "Bool" "liked" [] Decode.bool


status : SelectionSet Eptank.Enum.ImageStatus.ImageStatus Eptank.Object.Image
status =
    Object.selectionForField "Enum.ImageStatus.ImageStatus" "status" [] Eptank.Enum.ImageStatus.decoder


xreso : SelectionSet Int Eptank.Object.Image
xreso =
    Object.selectionForField "Int" "xreso" [] Decode.int


yreso : SelectionSet Int Eptank.Object.Image
yreso =
    Object.selectionForField "Int" "yreso" [] Decode.int
