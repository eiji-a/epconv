--- Picshare

module Update exposing (update, subscriptions, fetchFeed)

{-
import Html exposing (..)
import Html.Attributes exposing (class, disabled, placeholder, src, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Json.Decode.Pipeline exposing (hardcoded, required)
import Browser
-}
import Json.Decode exposing (Decoder, bool, decodeString, int, list, string, succeed)
import Http

import Types exposing (..)
import WebSocket

--baseUrl : String
--baseUrl = "https://programming-elm.com/"
--baseUrl = "http://localhost:4567/"

wsUrl : String
wsUrl =
  "wss://programming-elm.com/"

{-
initialModel : Model
initialModel =
  { feed = Nothing
  , error = Nothing
  , streamQueue = []
  }


init : () -> ( Model, Cmd Msg )
init () =
  ( initialModel, fetchFeed )

-}

fetchFeed : Int -> Cmd Msg
fetchFeed nimg =
  Http.get
    { url = baseUrl ++ "feed/" ++ (String.fromInt nimg)
    , expect = Http.expectJson LoadFeed (list photoDecoder)
    }

{-
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
-}

toggleLike : Photo -> Photo
toggleLike photo =
  { photo | liked = not photo.liked }

toggleTrash : Photo -> Photo
toggleTrash photo =
  let
    st =
      if photo.status == "discarded" then
        "checked"
      else
        "discarded"
  in
  { photo | status = st }

{-
updateComment : String -> Photo -> Photo
updateComment comment photo =
  { photo | newComment = comment }
-}

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
    Next ->
      ( model
      , fetchFeed 4
      )
    ToggleLike id ->
      ( { model
          | feed = updateFeed toggleLike id model.feed
        }
      , Cmd.none

      )
    ToggleTrash id ->
      ( { model
          | feed = updateFeed toggleTrash id model.feed
        }
      , Cmd.none

      )
    {-
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
    -}
    LoadFeed (Ok feed) ->
      ( { model | feed = Just feed }
      , WebSocket.listen wsUrl
      )
    LoadFeed (Err error) ->
      ( { model | error = Just error }
      , Cmd.none
      )
{-
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

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
{-
  WebSocket.receive
    (LoadStreamPhoto << decodeString photoDecoder)
-}

