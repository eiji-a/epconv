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
import RemoteData exposing (RemoteData)

import Eptank.Object.Image as Image

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

setLikeStatus : Int -> Bool -> Cmd Msg
setLikeStatus id fl =
  let
    st =
      if fl == True then
        "/on"
      else
        "/off"
  in
  Http.get
    { url = baseUrl ++ "like/" ++ (String.fromInt id) ++ st
    , expect = Http.expectJson Noop statusDecoder
    }

setLike : Int -> Cmd Msg
setLike id = setLikeStatus id True

setDislike : Int -> Cmd Msg
setDislike id = setLikeStatus id False

setStatus : Int -> PhotoStatus -> Cmd Msg
setStatus id stat =
  let
    s =
      case stat of
        Pending   -> "pending"
        Filed     -> "filed"
        Discarded -> "discarded"
        Deleted   -> "deleted"
  in
  Http.get
    { url = baseUrl ++ "status/" ++ (String.fromInt id) ++ "/" ++ s
    , expect = Http.expectJson Noop statusDecoder
    }


-- For GraphQL interface
{-
fetchFeedGraphQL : Int -> Cmd Msg
fetchFeedGraphQL nimg =
  query nimg
    |> Graphql.Http.queryRequest (baseUrl ++ "graphql")
    |> Graphql.Http.send (RemoteData.fromResult >> LoadFeedGraphql)
-}

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

like : Photo -> Photo
like photo =
  { photo | liked = True }

dislike : Photo -> Photo
dislike photo =
  { photo | liked = False }

trash : Photo -> Photo
trash photo =
  { photo | status = "discarded" }

undiscard : Photo -> Photo
undiscard photo =
  { photo | status = "filed" }

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

{-
imageToPhoto : Image -> Photo
imageToPhoto img =
  Photo img.id img.filename img.status img.xreso img.yreso img.filesize img.liked

imagesToPhotos : List Image -> List Photo
imagesToPhotos imgs =
  List.map imageToPhoto imgs
-}

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Noop _ ->
      ( model, Cmd.none )
    Next ->
      ( model
      , fetchFeed 4
      )
    Like id ->
      ( { model
          | feed = updateFeed like id model.feed
        }
      , setLike id
      )
    Dislike id ->
      ( { model
          | feed = updateFeed dislike id model.feed
        }
      , setDislike id
      )
    Trash id ->
      ( { model
          | feed = updateFeed trash id model.feed
        }
      , setStatus id Discarded
      )
    Undiscard id ->
      ( { model
          | feed = updateFeed undiscard id model.feed
        }
      , setStatus id Filed
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
    LoadFeedGraphql (NotAsked feed) ->
      ( model, Cmd.none )
    LoadFeedGraphql (Loading error) ->
      ( model, Cmd.none )
    LoadFeedGraphql (Failure error) ->
      ( model, Cmd.none )
    LoadFeedGraphql (Success response) ->
      let
        model2 =
          case response.success of
            False ->
              { feed = Nothing
              , error =
                case response.errors of
                  Just err ->
                    "Sorry, we get an error message:\n" ++
                    err ++ "\n" ++
                    "Please contact the server manager."
                  Nothing ->
                    """Sorry, we couldn't load your feed at this time.
                    Please try again later."""
              , streamQueue = []
              }
            _ ->
              { feed = imagesToPhotos response.images
              , error = ""
              , streamQueue = []
              }
      in
      ( model2, Cmd.none )
-}
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

