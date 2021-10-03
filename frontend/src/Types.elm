--- Picshare

module Types exposing (..)

import Json.Decode exposing (Decoder, bool, decodeString, int, list, string, succeed)
import Json.Decode.Pipeline exposing (hardcoded, required)

import Http
{-
import RemoteData exposing (RemoteData)

import Eptank.Object
import Eptank.Object.Image
import Eptank.Object.ImagesResult
import Eptank.Query as Query
import Graphql.Http
import Graphql.Operation exposing (RootQuery)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet, succeed, with)
-}

type alias Id =
  Int

type alias Tag =
  { id : Id
  , tag : String
  }

type PhotoStatus
  = Pending
  | Filed
  | Discarded
  | Deleted

type alias Photo =
  { id : Id
  , filename : String
  --, url : String
  , status : String
  , xreso : Int
  , yreso : Int
  , filesize : Int
  , liked : Bool
  , tags : List Int
  }

type alias Feed =
  List Photo

type alias Model =
  { feed : Maybe Feed
  , error : Maybe Http.Error
  , streamQueue : Feed
  }

tagDecoder : Decoder Tag
tagDecoder =
  succeed Tag
    |> required "id" int
    |> required "tag" string

{-
photoStatusDecoder : Decoder PhotoStatus
photoStatusDecoder =
  succeed PhotoStatus
    |> required ""
-}

photoDecoder : Decoder Photo
photoDecoder =
  succeed Photo
    |> required "id" int
    |> required "filename" string
    --|> required "url" string
    |> required "status" string
    |> required "xreso" int
    |> required "yreso" int
    |> required "filesize" int
    |> required "liked" bool
    |> required "tags" (list int)

type alias Status =
  { status : String }

statusDecoder : Decoder Status
statusDecoder =
  succeed Status
    |> required "status" string

{-
type alias ImagesResponse =
  { success : Bool
  , errors : List String
  , images : List Photo
  }

queryImages : Int -> SelectionSet ImagesResponse RootQuery
queryImages nimg =
  succeed ImagesResponse
    |> with (Query.images (\arg -> { arg | nimg = Present nimg }) responseSelection)

responseSelection : SelectionSet ImagesResponse Eptank.Object.ImagesResult
responseSelection =
  succeed ImagesResponse
    |> with Eptank.Object.ImagesResult.success
    |> with Eptank.Object.ImagesResult.errors
    |> with Eptank.Object.ImagesResult.images

imageSelection : SelectionSet Photo Eptank.Object.Image
imageSelection =
  succeed Photo
    |> with Eptank.Object.Image.id
    |> with Eptank.Object.Image.filename
    |> with Eptank.Object.Image.status
    |> with Eptank.Object.Image.xreso
    |> with Eptank.Object.Image.yreso
    |> with Eptank.Object.Image.filesize
    |> with Eptank.Object.Image.liked
-}

initialModel : Model
initialModel =
  { feed = Nothing
  , error = Nothing
  , streamQueue = []
  }

tagList : List Tag
tagList =
  [ { id = 1, tag = "pussy" }
  , { id = 2, tag = "big boobs" }
  , { id = 3, tag = "armpit" }
  , { id = 4, tag = "ass" }
  , { id = 5, tag = "beauty" }
  , { id = 6, tag = "full nude" }
  , { id = 7, tag = "nipples" }
  , { id = 8, tag = "sex" }
  ]

type Msg
  = Noop (Result Http.Error Status)
  | Next
  | Like Id
  | Dislike Id
  | Trash Id
  | Undiscard Id
--  | UpdateComment Id String
--  | SaveComment Id
  | LoadFeed (Result Http.Error Feed)
--  | LoadStreamPhoto (Result Json.Decode.Error Photo)
--  | FlushStreamQueue
--  | LoadFeedGraphql (RemoteData (Graphql.Http.Error ImagesResponse) ImagesResponse)

baseUrl : String
--baseUrl = "https://programming-elm.com/"
baseUrl = "http://localhost:4567/"

