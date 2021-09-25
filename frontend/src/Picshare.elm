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

{-
baseUrl : String
--baseUrl = "https://programming-elm.com/"
baseUrl = "http://localhost:4567/"

wsUrl : String
wsUrl =
  "wss://programming-elm.com/"
-}

initialModel : Model
initialModel =
  { feed = Nothing
  , error = Nothing
  , streamQueue = []
  }

init : () -> ( Model, Cmd Msg )
init () =
  ( initialModel, fetchFeed )

{-
fetchFeed : Cmd Msg
fetchFeed =
  Http.get
    { url = baseUrl ++ "feed"
    , expect = Http.expectJson LoadFeed (list photoDecoder)
    }


saveNewComment : Photo -> Photo
saveNewComment photo =
  let
    comment =
      String.trim photo.newComment
  in
  case comment of
    "" ->
      photo
    _ ->
      { photo
        | comments = photo.comments ++ [ comment ]
        , newComment = ""
      }

toggleLike : Photo -> Photo
toggleLike photo =
  { photo | liked = not photo.liked }

updateComment : String -> Photo -> Photo
updateComment comment photo =
  { photo | newComment = comment }

updatePhotoById : (Photo -> Photo) -> Id -> Feed -> Feed
updatePhotoById updatePhoto id feed =
  List.map
    (\photo ->
      if photo.id == id then
        updatePhoto photo
      else
        photo
    )
    feed

updateFeed : (Photo -> Photo) -> Id -> Maybe Feed -> Maybe Feed
updateFeed updatePhoto id maybeFeed =
  Maybe.map (updatePhotoById updatePhoto id) maybeFeed

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    ToggleLike id ->
      ( { model
          | feed = updateFeed toggleLike id model.feed
        }
      , fetchFeed --Cmd.none

      )
    UpdateComment id comment ->
      ( { model
          | feed = updateFeed (updateComment comment) id model.feed
        }
      , Cmd.none
      )
    SaveComment id ->
      ( { model
          | feed = updateFeed saveNewComment id model.feed
        }
      , Cmd.none
      )
    LoadFeed (Ok feed) ->
      ( { model | feed = Just feed }
      , WebSocket.listen wsUrl
      )
    LoadFeed (Err error) ->
      ( { model | error = Just error }
      , Cmd.none
      )
    LoadStreamPhoto (Ok photo) ->
      ( { model | streamQueue = photo :: model.streamQueue }
      , Cmd.none
      )
    LoadStreamPhoto (Err _) ->
      ( model
      , Cmd.none
      )
    FlushStreamQueue ->
      ( { model
          | feed = Maybe.map ((++) model.streamQueue) model.feed
          , streamQueue = []
        }
      , Cmd.none
      )
-}

main : Program () Model Msg
main =
  Browser.element
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

  


