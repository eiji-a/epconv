--- Picshare

module Picshare exposing (main)

import Browser

{-
import Json.Decode exposing (Decoder, bool, decodeString, int, list, string, succeed)
import Json.Decode.Pipeline exposing (hardcoded, required)
import Http
-}

import Types exposing (..)
import Update exposing (..)
import View exposing (..)
import WebSocket

initialModel : Model
initialModel =
  { feed = Nothing
  , error = Nothing
  , streamQueue = []
  }

init : () -> ( Model, Cmd Msg )
init () =
  ( initialModel, fetchFeed 4)

main : Program () Model Msg
main =
  Browser.element
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

  


